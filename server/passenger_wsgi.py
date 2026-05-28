"""WSGI proxy (Python, zero dependencies) for the Tayyibat iOS app.

Holds the Anthropic API key on the server and forwards meal-image analysis,
so the key never ships inside the app. Runs under cPanel "Setup Python App"
(Passenger): set the startup file to this file and the entry point to
`application`. Requires only the Python standard library.

Routes:
  GET  /health   -> {"ok": true}
  POST /analyze  -> {"image_base64": "...", "media_type": "image/jpeg"} -> result JSON
"""
import json
import os
import urllib.request
import urllib.error

API_KEY = os.environ.get("ANTHROPIC_API_KEY", "")
APP_TOKEN = os.environ.get("APP_TOKEN", "")
MODEL = "claude-opus-4-7"
ANTHROPIC_VERSION = "2023-06-01"

_HERE = os.path.dirname(os.path.abspath(__file__))
with open(os.path.join(_HERE, "tayyibat_rules.json"), "r", encoding="utf-8") as _f:
    RULES_JSON = _f.read()


def build_prompt():
    # Plain concatenation (not an f-string) so the JSON braces below stay literal.
    return (
        'أنت محلل صور طعام متخصص في نظام "الطيبات" الغذائي للدكتور ضياء العوضي.\n\n'
        'قواعد النظام:\n'
        + RULES_JSON +
        '\n\n'
        'حلل الصورة المرفقة وأرجع JSON فقط (بدون markdown ولا preamble) بهذه البنية بالضبط:\n\n'
        '{\n'
        '  "identified_items": [\n'
        '    {\n'
        '      "name_ar": "اسم الطعام بالعربية",\n'
        '      "confidence": 0.0,\n'
        '      "estimated_portion": "حصة صغيرة | متوسطة | كبيرة",\n'
        '      "verdict": "tayyib | khabith | conditional",\n'
        '      "category": "نشويات | لحوم | خضروات | فواكه | إلخ",\n'
        '      "reasoning_ar": "السبب بالعربية",\n'
        '      "rule_violated": "اسم القاعدة المخالفة أو null"\n'
        '    }\n'
        '  ],\n'
        '  "overall_score": 0,\n'
        '  "score_label_ar": "ممتاز | جيد | متوسط | ضعيف",\n'
        '  "score_explanation_ar": "جملتين أو ثلاث بالعربية",\n'
        '  "improvement_suggestions_ar": ["اقتراح 1", "اقتراح 2"],\n'
        '  "warnings": []\n'
        '}\n\n'
        'منطق النقاط:\n'
        '- كل عنصر طيب: نقاط كاملة بحسب نسبة ظهوره في الطبق\n'
        '- كل عنصر مشروط: نصف النقاط\n'
        '- كل عنصر خبيث: صفر + خصم بنسبة ظهوره\n'
        '- لو فيه أي عنصر ممنوع صراحة (دجاج، بيض، بقوليات، خضروات ورقية) ظاهر بوضوح، الحد الأقصى للنتيجة = 60\n\n'
        'كن متحفظاً — إذا كنت غير متأكد من عنصر، ضع confidence أقل من 0.7 ونبّه المستخدم للمراجعة في warnings.'
    )


def strip_fences(text):
    t = (text or "").strip()
    if t.startswith("```"):
        t = t.replace("```json", "").replace("```", "").strip()
    a = t.find("{")
    b = t.rfind("}")
    if a != -1 and b != -1:
        t = t[a:b + 1]
    return t


def _respond(start_response, status, obj):
    body = json.dumps(obj, ensure_ascii=False).encode("utf-8")
    headers = [
        ("Content-Type", "application/json; charset=utf-8"),
        ("Content-Length", str(len(body))),
        ("Access-Control-Allow-Origin", "*"),
        ("Access-Control-Allow-Headers", "content-type,x-app-token"),
        ("Access-Control-Allow-Methods", "POST,GET,OPTIONS"),
    ]
    start_response(status, headers)
    return [body]


def application(environ, start_response):
    method = environ.get("REQUEST_METHOD", "GET")
    path = environ.get("PATH_INFO", "/")

    if method == "OPTIONS":
        return _respond(start_response, "200 OK", {})
    if method == "GET" and path == "/health":
        return _respond(start_response, "200 OK", {"ok": True})
    if method != "POST" or not path.startswith("/analyze"):
        return _respond(start_response, "404 Not Found", {"error": "غير موجود"})
    if APP_TOKEN and environ.get("HTTP_X_APP_TOKEN", "") != APP_TOKEN:
        return _respond(start_response, "401 Unauthorized", {"error": "غير مصرّح"})
    if not API_KEY:
        return _respond(start_response, "500 Internal Server Error",
                        {"error": "الخادم غير مهيّأ: متغيّر ANTHROPIC_API_KEY مفقود"})

    try:
        length = int(environ.get("CONTENT_LENGTH") or 0)
    except ValueError:
        length = 0
    raw_in = environ["wsgi.input"].read(length) if length > 0 else b""

    try:
        payload = json.loads(raw_in.decode("utf-8"))
    except Exception:
        return _respond(start_response, "400 Bad Request", {"error": "جسم الطلب غير صالح"})

    image_b64 = payload.get("image_base64")
    media_type = payload.get("media_type") or "image/jpeg"
    if not image_b64:
        return _respond(start_response, "400 Bad Request", {"error": "image_base64 مطلوب"})

    anthropic_body = json.dumps({
        "model": MODEL,
        "max_tokens": 2000,
        "messages": [{
            "role": "user",
            "content": [
                {"type": "image", "source": {"type": "base64", "media_type": media_type, "data": image_b64}},
                {"type": "text", "text": build_prompt()},
            ],
        }],
    }).encode("utf-8")

    req = urllib.request.Request(
        "https://api.anthropic.com/v1/messages",
        data=anthropic_body,
        headers={
            "x-api-key": API_KEY,
            "anthropic-version": ANTHROPIC_VERSION,
            "content-type": "application/json",
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            raw = resp.read().decode("utf-8")
    except urllib.error.HTTPError as e:
        raw = e.read().decode("utf-8", "replace")
        msg = "خطأ من Anthropic ({})".format(e.code)
        try:
            msg = json.loads(raw)["error"]["message"]
        except Exception:
            pass
        return _respond(start_response, "{} Upstream Error".format(e.code), {"error": msg})
    except Exception as e:
        return _respond(start_response, "502 Bad Gateway",
                        {"error": "تعذّر الاتصال بـ Anthropic: {}".format(e)})

    try:
        data = json.loads(raw)
        text = "".join(b.get("text", "") for b in data.get("content", []) if b.get("type") == "text")
        result = json.loads(strip_fences(text))
        return _respond(start_response, "200 OK", result)
    except Exception:
        return _respond(start_response, "502 Bad Gateway", {"error": "تعذّر تحليل نتيجة النموذج"})
