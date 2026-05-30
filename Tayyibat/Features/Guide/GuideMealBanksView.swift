import SwiftUI

/// ٠٧ — بنوك الوجبات (نظرة سريعة على البنوك الأربعة).
/// التفاصيل والإضافة للخطة تأتي في مرحلة لاحقة.
struct GuideMealBanksView: View {
    private let banks: [Bank] = [
        Bank(emoji: "🌅", titleAr: "بنك الفطار", subtitleAr: "أفكار سريعة ومشبعة",
             samples: ["تمر وماء", "بطاطس مهروسة بزبدة طبيعية", "أرز بسيط بالسمن", "توست كامل وجبنة معتقة (اعتدال)"]),
        Bank(emoji: "🍽", titleAr: "بنك الغداء", subtitleAr: "أطباق رئيسية واضحة",
             samples: ["أرز ولحم", "كبدة وبطاطس", "سمك وأرز", "كوارع أو حمام"]),
        Bank(emoji: "🌙", titleAr: "بنك العشاء", subtitleAr: "خفيف وواضح",
             samples: ["بطاطس مسلوقة بزبدة", "أرز خفيف", "جبنة معتقة مع توست كامل", "تمر وماء"]),
        Bank(emoji: "🍯", titleAr: "بنك السناك والحلويات", subtitleAr: "باعتدال، ليس عادة مستمرة",
             samples: ["تمر (كمية صغيرة)", "عسل طبيعي (داخل وصفة)", "فاكهة طبيعية (تدخل تدريجياً)"])
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                CardContainer {
                    HStack(spacing: 10) {
                        Image(systemName: "tray.full.fill")
                            .foregroundStyle(Theme.primary)
                        Text("أفكار وجبات مرتّبة حسب الوقت — اختر، صوِّر، سجِّل.")
                            .font(.bodyText)
                            .foregroundStyle(Theme.textPrimary)
                    }
                }

                ForEach(banks) { bank in
                    CardContainer {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 12) {
                                Text(bank.emoji).font(.system(size: 30))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(bank.titleAr)
                                        .font(.cardTitle.weight(.semibold))
                                        .foregroundStyle(Theme.textPrimary)
                                    Text(bank.subtitleAr)
                                        .font(.caption)
                                        .foregroundStyle(Theme.textSecondary)
                                }
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(bank.samples, id: \.self) { item in
                                    HStack(spacing: 6) {
                                        Circle().fill(Theme.primary.opacity(0.6)).frame(width: 5, height: 5)
                                        Text(item)
                                            .font(.bodyText)
                                            .foregroundStyle(Theme.textPrimary)
                                    }
                                }
                            }
                        }
                    }
                }

                CardContainer {
                    HStack(spacing: 10) {
                        Image(systemName: "hourglass").foregroundStyle(Theme.gold)
                        Text("إضافة الوجبات إلى خطة اليوم بضغطة تأتي قريباً.")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }
            .padding(16)
        }
        .background(Theme.background)
        .navigationTitle("بنك الوجبات")
        .navigationBarTitleDisplayMode(.inline)
    }

    private struct Bank: Identifiable {
        let id = UUID()
        let emoji: String
        let titleAr: String
        let subtitleAr: String
        let samples: [String]
    }
}
