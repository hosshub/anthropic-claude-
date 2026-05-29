package com.tayyibat.app.service

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Base64
import com.tayyibat.app.config.AppConfig
import com.tayyibat.app.data.SecureStore
import com.tayyibat.app.data.model.AnalysisResult
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.add
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import kotlinx.serialization.json.put
import kotlinx.serialization.json.putJsonArray
import java.io.ByteArrayOutputStream
import java.net.HttpURLConnection
import java.net.URL

/** أخطاء تحليل الوجبة برسائل عربية مفهومة. */
class GeminiApiException(override val message: String) : Exception(message)

/** عميل تحليل صور الوجبات وفق نظام الطيبات عبر Google Gemini (مباشرةً أو عبر الوسيط). */
class GeminiApiService(private val appContext: Context) {

    private val json = Json { ignoreUnknownKeys = true; isLenient = true }

    /** يحلل الصورة: عبر الوسيط (proxy) إن كان مُعدّاً، وإلا مباشرةً بمفتاح المستخدم. */
    suspend fun analyze(imageBytes: ByteArray): AnalysisResult = withContext(Dispatchers.IO) {
        val jpeg = prepareJpeg(imageBytes) ?: throw GeminiApiException("تعذّر تجهيز الصورة للتحليل.")
        if (AppConfig.PROXY_URL.isNotEmpty()) analyzeViaProxy(jpeg) else analyzeDirect(jpeg)
    }

    // وضع الوسيط (المفتاح على الخادم — مناسب للنشر). الحمولة لا تتغيّر؛ الخادم يخاطب Gemini.
    private fun analyzeViaProxy(jpeg: ByteArray): AnalysisResult {
        val payload = buildJsonObject {
            put("image_base64", Base64.encodeToString(jpeg, Base64.NO_WRAP))
            put("media_type", "image/jpeg")
        }
        val headers = buildMap {
            put("content-type", "application/json")
            if (AppConfig.APP_TOKEN.isNotEmpty()) put("x-app-token", AppConfig.APP_TOKEN)
        }
        val (code, body) = post(AppConfig.PROXY_URL, headers, payload.toString())
        if (code !in 200..299) {
            throw GeminiApiException("خطأ من الخادم ($code): ${extractApiError(body) ?: "حدث خطأ غير متوقع"}")
        }
        // الوسيط يُرجع JSON النتيجة مباشرةً.
        return runCatching { json.decodeFromString(AnalysisResult.serializer(), body) }
            .getOrElse {
                val stripped = stripFences(body)
                runCatching { json.decodeFromString(AnalysisResult.serializer(), stripped) }
                    .getOrElse { throw GeminiApiException("تعذّر فهم نتيجة التحليل: رد غير متوقع من الوسيط") }
            }
    }

    // الوضع المباشر (مفتاح المستخدم في التخزين الآمن — للتطوير/الاستخدام الشخصي)
    private fun analyzeDirect(jpeg: ByteArray): AnalysisResult {
        val apiKey = SecureStore.loadApiKey(appContext)
            ?: throw GeminiApiException("لم يتم إدخال مفتاح Gemini API. أضِفه من الإعدادات.")

        val endpoint = "https://generativelanguage.googleapis.com/v1beta/models/$MODEL:generateContent"

        val body = buildJsonObject {
            putJsonArray("contents") {
                add(buildJsonObject {
                    putJsonArray("parts") {
                        add(buildJsonObject {
                            put("inline_data", buildJsonObject {
                                put("mime_type", "image/jpeg")
                                put("data", Base64.encodeToString(jpeg, Base64.NO_WRAP))
                            })
                        })
                        add(buildJsonObject { put("text", prompt()) })
                    }
                })
            }
            put("generationConfig", buildJsonObject {
                put("temperature", 0.2)
                put("responseMimeType", "application/json")
            })
        }

        val headers = mapOf(
            "content-type" to "application/json",
            "x-goog-api-key" to apiKey,
        )
        val (code, resp) = post(endpoint, headers, body.toString())
        if (code !in 200..299) {
            throw GeminiApiException("خطأ من الخادم ($code): ${extractApiError(resp) ?: "حدث خطأ غير متوقع"}")
        }
        val text = extractText(resp) ?: throw GeminiApiException("وصل رد فارغ من الخادم.")
        val stripped = stripFences(text)
        return runCatching { json.decodeFromString(AnalysisResult.serializer(), stripped) }
            .getOrElse { throw GeminiApiException("تعذّر فهم نتيجة التحليل: ${it.message}") }
    }

    // أدوات الشبكة
    private fun post(urlString: String, headers: Map<String, String>, body: String): Pair<Int, String> {
        val url = URL(urlString)
        val conn = url.openConnection() as HttpURLConnection
        return try {
            conn.requestMethod = "POST"
            conn.doOutput = true
            conn.connectTimeout = 60_000
            conn.readTimeout = 60_000
            headers.forEach { (k, v) -> conn.setRequestProperty(k, v) }
            conn.outputStream.use { it.write(body.toByteArray(Charsets.UTF_8)) }
            val code = conn.responseCode
            val stream = if (code in 200..299) conn.inputStream else conn.errorStream
            val text = stream?.bufferedReader()?.use { it.readText() } ?: ""
            code to text
        } catch (e: Exception) {
            throw GeminiApiException("تعذّر الاتصال بالخادم: ${e.message}")
        } finally {
            conn.disconnect()
        }
    }

    /** يستخرج نص الرد من بنية ردّ Gemini: candidates[0].content.parts[*].text */
    private fun extractText(data: String): String? = runCatching {
        val obj = json.parseToJsonElement(data).jsonObject
        val candidates = obj["candidates"]?.jsonArray ?: return null
        val first = candidates.firstOrNull()?.jsonObject ?: return null
        val parts = first["content"]?.jsonObject?.get("parts")?.jsonArray ?: return null
        parts.joinToString("") { el ->
            el.jsonObject["text"]?.jsonPrimitive?.content ?: ""
        }.ifEmpty { null }
    }.getOrNull()

    /** شكل خطأ Gemini: { "error": { "message": "..." } } */
    private fun extractApiError(data: String): String? = runCatching {
        val obj = json.parseToJsonElement(data).jsonObject
        obj["error"]?.jsonObject?.get("message")?.jsonPrimitive?.content
            ?: obj["error"]?.jsonPrimitive?.content
    }.getOrNull()

    companion object {
        const val MODEL = "gemini-2.5-flash"

        /** يزيل أسوار markdown (```json ... ```) إن وُجدت ويعزل كائن JSON. */
        fun stripFences(text: String): String {
            var t = text.trim()
            if (t.startsWith("```")) {
                t = t.replace("```json", "").replace("```", "").trim()
            }
            val start = t.indexOf('{')
            val end = t.lastIndexOf('}')
            if (start >= 0 && end >= start) t = t.substring(start, end + 1)
            return t
        }

        /** يصغّر الصورة ويحوّلها JPEG لتقليل حجم الطلب. */
        fun prepareJpeg(data: ByteArray, maxDimension: Int = 1024): ByteArray? {
            val bitmap = BitmapFactory.decodeByteArray(data, 0, data.size) ?: return null
            val scale = minOf(1f, maxDimension.toFloat() / maxOf(bitmap.width, bitmap.height))
            val target = if (scale < 1f) {
                Bitmap.createScaledBitmap(
                    bitmap,
                    (bitmap.width * scale).toInt().coerceAtLeast(1),
                    (bitmap.height * scale).toInt().coerceAtLeast(1),
                    true,
                )
            } else bitmap
            val out = ByteArrayOutputStream()
            target.compress(Bitmap.CompressFormat.JPEG, 70, out)
            return out.toByteArray()
        }

        fun prompt(): String = """
            أنت محلل صور طعام متخصص في نظام "الطيبات" الغذائي للدكتور ضياء العوضي.

            قواعد النظام:
            ${RulesService.rawJson}

            حلل الصورة المرفقة وأرجع JSON فقط (بدون markdown ولا preamble) بهذه البنية بالضبط:

            {
              "identified_items": [
                {
                  "name_ar": "اسم الطعام بالعربية",
                  "confidence": 0.0,
                  "estimated_portion": "حصة صغيرة | متوسطة | كبيرة",
                  "verdict": "tayyib | khabith | conditional",
                  "category": "نشويات | لحوم | خضروات | فواكه | إلخ",
                  "reasoning_ar": "السبب بالعربية",
                  "rule_violated": "اسم القاعدة المخالفة أو null"
                }
              ],
              "overall_score": 0,
              "score_label_ar": "ممتاز | جيد | متوسط | ضعيف",
              "score_explanation_ar": "جملتين أو ثلاث بالعربية",
              "improvement_suggestions_ar": ["اقتراح 1", "اقتراح 2"],
              "warnings": []
            }

            منطق النقاط:
            - كل عنصر طيب: نقاط كاملة بحسب نسبة ظهوره في الطبق
            - كل عنصر مشروط: نصف النقاط
            - كل عنصر خبيث: صفر + خصم بنسبة ظهوره
            - لو فيه أي عنصر ممنوع صراحة (دجاج، بيض، بقوليات، خضروات ورقية) ظاهر بوضوح، الحد الأقصى للنتيجة = 60

            كن متحفظاً — إذا كنت غير متأكد من عنصر، ضع confidence أقل من 0.7 ونبّه المستخدم للمراجعة في warnings.
        """.trimIndent()
    }
}
