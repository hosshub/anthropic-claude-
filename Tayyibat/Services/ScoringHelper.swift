import Foundation

/// إعادة حساب نسبة الالتزام محلياً بعد تعديل المستخدم لعناصر الوجبة.
/// (التحليل الأصلي يأتي من Claude؛ هذا يُستخدم فقط عند التعديل اليدوي.)
enum ScoringHelper {
    private static func portionWeight(_ portion: String) -> Double {
        if portion.contains("صغير") { return 1 }
        if portion.contains("كبير") { return 3 }
        return 2 // متوسطة أو غير معروف
    }

    private static func verdictFactor(_ verdict: Verdict) -> Double {
        switch verdict {
        case .tayyib: return 1.0
        case .conditional: return 0.5
        case .khabith: return 0.0
        }
    }

    /// يحسب النتيجة من العناصر مع تطبيق سقف 60 عند وجود عنصر خبيث صريح.
    static func recompute(items: [FoodItem]) -> Int {
        guard !items.isEmpty else { return 0 }

        var totalWeight = 0.0
        var earned = 0.0
        var hasKhabith = false

        for item in items {
            let w = portionWeight(item.estimatedPortion)
            totalWeight += w
            earned += w * verdictFactor(item.verdict)
            if item.verdict == .khabith { hasKhabith = true }
        }

        guard totalWeight > 0 else { return 0 }
        var score = Int((earned / totalWeight * 100).rounded())
        if hasKhabith { score = min(score, 60) }
        return max(0, min(100, score))
    }
}
