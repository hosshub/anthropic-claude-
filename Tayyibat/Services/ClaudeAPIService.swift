import Foundation
import UIKit

enum ClaudeAPIError: LocalizedError {
    case missingKey
    case invalidImage
    case network(String)
    case http(Int, String)
    case emptyResponse
    case decoding(String)

    var errorDescription: String? {
        switch self {
        case .missingKey:
            return "لم يتم إدخال مفتاح Claude API. أضِفه من الإعدادات."
        case .invalidImage:
            return "تعذّر تجهيز الصورة للتحليل."
        case .network(let m):
            return "تعذّر الاتصال بالخادم: \(m)"
        case .http(let code, let m):
            return "خطأ من الخادم (\(code)): \(m)"
        case .emptyResponse:
            return "وصل رد فارغ من الخادم."
        case .decoding(let m):
            return "تعذّر فهم نتيجة التحليل: \(m)"
        }
    }
}

/// عميل Claude API لتحليل صور الوجبات وفق نظام الطيبات.
struct ClaudeAPIService {
    static let model = "claude-opus-4-7"
    private static let endpoint = URL(string: "https://api.anthropic.com/v1/messages")!
    private static let anthropicVersion = "2023-06-01"

    func analyze(imageData: Data) async throws -> AnalysisResult {
        guard let apiKey = KeychainService.loadAPIKey(), !apiKey.isEmpty else {
            throw ClaudeAPIError.missingKey
        }
        guard let jpeg = Self.prepareJPEG(from: imageData) else {
            throw ClaudeAPIError.invalidImage
        }

        let body: [String: Any] = [
            "model": Self.model,
            "max_tokens": 2000,
            "messages": [[
                "role": "user",
                "content": [
                    [
                        "type": "image",
                        "source": [
                            "type": "base64",
                            "media_type": "image/jpeg",
                            "data": jpeg.base64EncodedString()
                        ]
                    ],
                    ["type": "text", "text": Self.prompt]
                ]
            ]]
        ]

        var request = URLRequest(url: Self.endpoint)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue(Self.anthropicVersion, forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.timeoutInterval = 60

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw ClaudeAPIError.network(error.localizedDescription)
        }

        guard let http = response as? HTTPURLResponse else {
            throw ClaudeAPIError.emptyResponse
        }
        guard (200...299).contains(http.statusCode) else {
            let msg = Self.extractAPIError(from: data) ?? "حدث خطأ غير متوقع"
            throw ClaudeAPIError.http(http.statusCode, msg)
        }

        let text = try Self.extractText(from: data)
        let json = Self.stripFences(text)
        guard let jsonData = json.data(using: .utf8) else {
            throw ClaudeAPIError.decoding("ترميز غير صالح")
        }
        do {
            return try JSONDecoder().decode(AnalysisResult.self, from: jsonData)
        } catch {
            throw ClaudeAPIError.decoding(error.localizedDescription)
        }
    }

    // MARK: - Response parsing

    /// يستخرج نص الرد من بنية رسالة Anthropic.
    private static func extractText(from data: Data) throws -> String {
        guard let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = obj["content"] as? [[String: Any]] else {
            throw ClaudeAPIError.emptyResponse
        }
        let text = content
            .compactMap { $0["type"] as? String == "text" ? $0["text"] as? String : nil }
            .joined()
        if text.isEmpty { throw ClaudeAPIError.emptyResponse }
        return text
    }

    private static func extractAPIError(from data: Data) -> String? {
        guard let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let err = obj["error"] as? [String: Any],
              let message = err["message"] as? String else {
            return nil
        }
        return message
    }

    /// يزيل أسوار markdown (```json ... ```) إن وُجدت ويعزل كائن JSON.
    static func stripFences(_ text: String) -> String {
        var t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.hasPrefix("```") {
            t = t.replacingOccurrences(of: "```json", with: "")
                 .replacingOccurrences(of: "```", with: "")
                 .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let start = t.firstIndex(of: "{"), let end = t.lastIndex(of: "}") {
            t = String(t[start...end])
        }
        return t
    }

    // MARK: - Image prep

    /// يصغّر الصورة ويحوّلها JPEG لتقليل حجم الطلب.
    static func prepareJPEG(from data: Data, maxDimension: CGFloat = 1024) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let size = image.size
        let scale = min(1, maxDimension / max(size.width, size.height))
        let target = CGSize(width: size.width * scale, height: size.height * scale)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: target, format: format)
        let resized = renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: target)) }
        return resized.jpegData(compressionQuality: 0.7)
    }

    // MARK: - Prompt

    static var prompt: String {
        """
        أنت محلل صور طعام متخصص في نظام "الطيبات" الغذائي للدكتور ضياء العوضي.

        قواعد النظام:
        \(RulesService.shared.rawJSON)

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
        """
    }
}
