import SwiftUI

/// ٠٥ — طبق الطيبات: الصيغة الأساسية (نشويات + بروتين + دهون طبيعية).
struct GuideTayyibatPlateView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                CardContainer {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("الصيغة الأساسية", systemImage: "circle.grid.cross.fill")
                            .font(.sectionTitle.weight(.bold))
                            .foregroundStyle(Theme.primary)
                        Text("أرز أو بطاطس + بروتين مناسب + دهون طبيعية")
                            .font(.bodyText)
                            .foregroundStyle(Theme.textPrimary)
                            .lineSpacing(5)
                    }
                }

                plateBlock(
                    title: "نشويات",
                    body: "اختر بين الأرز أو البطاطس بأي طريقة تحبها (مسلوقة، مشوية، مقلية…).",
                    icon: "leaf.fill"
                )
                plateBlock(
                    title: "بروتين",
                    body: "لحم أحمر، كبدة، كوارع، أرنب، حمام، أو سمك مستوٍ تماماً. تجنّب الدواجن والبيض.",
                    icon: "fork.knife"
                )
                plateBlock(
                    title: "دهون طبيعية",
                    body: "سمن بلدي، زبدة طبيعية، زيت زيتون، أو زيتون — باعتدال.",
                    icon: "drop.fill"
                )

                CardContainer {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("القاعدة الذهبية", systemImage: "star.fill")
                            .font(.cardTitle.weight(.semibold))
                            .foregroundStyle(Theme.gold)
                        Text("بسّط مكونات الوجبة، وتوقّف قبل الامتلاء، وراقب استجابة جسمك.")
                            .font(.bodyText)
                            .foregroundStyle(Theme.textPrimary)
                            .lineSpacing(4)
                    }
                }

                MedicalDisclaimerFooter()
                    .padding(.top, 4)
            }
            .padding(16)
        }
        .background(Theme.background)
        .navigationTitle("طبق الطيبات")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func plateBlock(title: String, body: String, icon: String) -> some View {
        CardContainer {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(Theme.primary)
                    .frame(width: 30)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.cardTitle.weight(.semibold))
                        .foregroundStyle(Theme.primary)
                    Text(body)
                        .font(.bodyText)
                        .foregroundStyle(Theme.textPrimary)
                        .lineSpacing(4)
                }
            }
        }
    }
}
