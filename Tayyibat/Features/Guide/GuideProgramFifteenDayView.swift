import SwiftUI

/// ٠٦ — برنامج ١٥ يوم (نظرة سريعة على المراحل الأربع).
/// التفاصيل اليومية وواجهة المتابعة تأتي في مرحلة لاحقة من الخطة.
struct GuideProgramFifteenDayView: View {
    private let phases: [Phase] = [
        Phase(number: "١", days: "الأيام ١–٣", titleAr: "تهدئة الفوضى الغذائية",
              focusAr: "وجبات بسيطة، مكونات قليلة، وتقليل المصنع.",
              color: Color(hex: 0xA8D5BA)),
        Phase(number: "٢", days: "الأيام ٤–٧", titleAr: "بناء الروتين",
              focusAr: "الأكل عند الجوع الحقيقي وتقليل السناكات.",
              color: Color(hex: 0x7FBC8C)),
        Phase(number: "٣", days: "الأيام ٨–١١", titleAr: "تنظيم البروتين",
              focusAr: "استخدام البروتين الحيواني بذكاء حسب الاستجابة.",
              color: Color(hex: 0x4F9C5F)),
        Phase(number: "٤", days: "الأيام ١٢–١٥", titleAr: "تثبيت النظام",
              focusAr: "معرفة الوجبات التي تعطي راحة وشبعاً بدون ثقل.",
              color: Color(hex: 0x147A4A))
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                CardContainer {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("الرحلة بدل الجدول الممل", systemImage: "calendar")
                            .font(.sectionTitle.weight(.bold))
                            .foregroundStyle(Theme.primary)
                        Text("ليس جدولاً جامداً، بل رحلة تدريجية بأربع مراحل. كل مرحلة تبني على ما قبلها.")
                            .font(.bodyText)
                            .foregroundStyle(Theme.textSecondary)
                            .lineSpacing(4)
                    }
                }

                ForEach(phases) { phase in
                    CardContainer {
                        HStack(alignment: .top, spacing: 12) {
                            ZStack {
                                Circle().fill(phase.color).frame(width: 44, height: 44)
                                Text(phase.number)
                                    .font(.cardTitle.weight(.bold))
                                    .foregroundStyle(.white)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text(phase.titleAr)
                                    .font(.cardTitle.weight(.semibold))
                                    .foregroundStyle(Theme.textPrimary)
                                Text(phase.days)
                                    .font(.caption)
                                    .foregroundStyle(Theme.textSecondary)
                                Text(phase.focusAr)
                                    .font(.bodyText)
                                    .foregroundStyle(Theme.textPrimary)
                                    .lineSpacing(4)
                                    .padding(.top, 2)
                            }
                        }
                    }
                }

                CardContainer {
                    HStack(spacing: 10) {
                        Image(systemName: "hourglass")
                            .foregroundStyle(Theme.gold)
                        Text("متابعة يوم-بيوم وتذكيرات البرنامج تأتي قريباً.")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }
            .padding(16)
        }
        .background(Theme.background)
        .navigationTitle("برنامج ١٥ يوم")
        .navigationBarTitleDisplayMode(.inline)
    }

    private struct Phase: Identifiable {
        let id = UUID()
        let number: String
        let days: String
        let titleAr: String
        let focusAr: String
        let color: Color
    }
}
