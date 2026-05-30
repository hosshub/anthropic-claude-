import Foundation

/// إعادة حساب نسبة الالتزام محلياً بعد تعديل المستخدم لعناصر الوجبة.
/// نسخة 2: قائم على إشارات الألوان (أخضر/أصفر/أحمر). إن غاب التصنيف الصريح
/// (بيانات v1 قبل الترقية)، يُشتقّ من حكم العنصر القديم تلقائياً عبر `FoodItem.zone`.
enum ScoringHelper {
    private static func portionWeight(_ portion: String) -> Double {
        if portion.contains("صغير") { return 1 }
        if portion.contains("كبير") { return 3 }
        return 2 // متوسطة أو غير معروف
    }

    private static func zoneFactor(_ zone: FoodZone) -> Double {
        switch zone {
        case .green: return 1.0
        case .yellow: return 0.6
        case .red: return 0.0
        }
    }

    /// يحسب النتيجة من العناصر مع تطبيق سقف 50 عند وجود عنصر أحمر مرئي بثقة.
    static func recompute(items: [FoodItem]) -> Int {
        guard !items.isEmpty else { return 0 }

        var totalWeight = 0.0
        var earned = 0.0
        var hasVisibleRed = false

        for item in items {
            let w = portionWeight(item.estimatedPortion)
            totalWeight += w
            earned += w * zoneFactor(item.zone)
            if item.zone == .red, item.confidence >= 0.7 { hasVisibleRed = true }
        }

        guard totalWeight > 0 else { return 0 }
        var score = Int((earned / totalWeight * 100).rounded())
        if hasVisibleRed { score = min(score, 50) }
        return max(0, min(100, score))
    }
}
