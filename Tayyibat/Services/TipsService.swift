import Foundation
import SwiftData

private struct TipBankFile: Codable {
    struct Entry: Codable { var category: String; var text: String }
    var version: String
    var tips: [Entry]
}

/// يدير بنك النصائح: التحميل، التخزين في SwiftData، والتدوير بدون تكرار.
enum TipsService {
    private static let recentWindow = 10

    /// يحمّل النصائح من JSON إلى SwiftData إذا لم تكن موجودة بعد.
    static func seedIfNeeded(context: ModelContext) {
        let count = (try? context.fetchCount(FetchDescriptor<NotificationTip>())) ?? 0
        guard count == 0 else { return }
        guard let url = Bundle.main.url(forResource: "tips_bank", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let bank = try? JSONDecoder().decode(TipBankFile.self, from: data) else {
            return
        }
        for entry in bank.tips {
            let category = TipCategory(rawValue: entry.category) ?? .general
            context.insert(NotificationTip(category: category, textAr: entry.text))
        }
        try? context.save()
    }

    /// نصيحة اليوم للرئيسية — ثابتة خلال اليوم وتتغيّر يومياً.
    static func tipOfTheDay(context: ModelContext) -> String {
        // ترتيب ثابت (بحسب المعرّف) كي لا تتغيّر نصيحة اليوم بين عمليات التشغيل.
        let pool = fetch(categories: [.morning, .general], context: context)
            .sorted { $0.id.uuidString < $1.id.uuidString }
        guard !pool.isEmpty else { return "تذكّر: كُل عند الجوع الحقيقي، واختر من الطيبات." }
        let dayIndex = Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 0
        return pool[dayIndex % pool.count].textAr
    }

    /// يختار نصيحة من فئة معيّنة متجنباً آخر النصائح التي ظهرت، ويعلّمها كمعروضة.
    @discardableResult
    static func nextTip(for category: TipCategory, context: ModelContext) -> String? {
        let pool = fetch(categories: [category], context: context)
        guard !pool.isEmpty else { return nil }

        let recentIDs = Set(recentlyShown(context: context).map(\.id))
        let candidates = pool.filter { !recentIDs.contains($0.id) }
        // الأقدم ظهوراً أولاً (nil يعني لم يظهر بعد).
        let chosen = (candidates.isEmpty ? pool : candidates)
            .sorted { ($0.lastShownAt ?? .distantPast) < ($1.lastShownAt ?? .distantPast) }
            .first

        chosen?.lastShownAt = .now
        try? context.save()
        return chosen?.textAr
    }

    // MARK: - Helpers

    private static func fetch(categories: [TipCategory], context: ModelContext) -> [NotificationTip] {
        let raws = Set(categories.map(\.rawValue))
        let all = (try? context.fetch(FetchDescriptor<NotificationTip>())) ?? []
        return all.filter { raws.contains($0.categoryRaw) }
    }

    private static func recentlyShown(context: ModelContext) -> [NotificationTip] {
        let all = (try? context.fetch(FetchDescriptor<NotificationTip>())) ?? []
        return all
            .filter { $0.lastShownAt != nil }
            .sorted { ($0.lastShownAt ?? .distantPast) > ($1.lastShownAt ?? .distantPast) }
            .prefix(recentWindow)
            .map { $0 }
    }
}
