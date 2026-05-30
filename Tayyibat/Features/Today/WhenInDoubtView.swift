import SwiftUI

/// مساعد "عندما تحتار" — ملخّص ذهبي + ٣ إجراءات سريعة.
struct WhenInDoubtView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showCapture = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    summarySection
                    actionsSection
                    MedicalDisclaimerFooter()
                        .padding(.top, 4)
                }
                .padding(20)
            }
            .background(Theme.background)
            .navigationTitle("عندما تحتار")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("إغلاق") { dismiss() }
                }
            }
            .fullScreenCover(isPresented: $showCapture) {
                CaptureFlowView()
            }
        }
    }

    // MARK: - Summary

    private var summarySection: some View {
        VStack(spacing: 12) {
            summaryCard(
                color: Theme.primary,
                icon: "checkmark.seal.fill",
                title: "اختر",
                body: "أرز أو بطاطس + بروتين مناسب + دهون طبيعية."
            )
            summaryCard(
                color: Theme.khabith,
                icon: "xmark.octagon.fill",
                title: "امنع تماماً",
                body: "الفراخ والبيض، الحليب ومشتقاته، البقوليات، المُصنّع، الزيوت الصناعية."
            )
            summaryCard(
                color: Theme.gold,
                icon: "exclamationmark.triangle.fill",
                title: "استخدم باعتدال",
                body: "الأجبان المعتقة، الفاكهة، العسل، التمر، القهوة، والشاي المحدود."
            )
            summaryCard(
                color: Theme.textSecondary,
                icon: "eye.fill",
                title: "راقب",
                body: "الهضم، الطاقة، النوم، والشبع."
            )
        }
    }

    private func summaryCard(color: Color, icon: String, title: String, body: String) -> some View {
        CardContainer {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.title3)
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.cardTitle.weight(.bold))
                        .foregroundStyle(color)
                    Text(body)
                        .font(.bodyText)
                        .foregroundStyle(Theme.textPrimary)
                        .lineSpacing(4)
                }
            }
        }
    }

    // MARK: - Actions

    private var actionsSection: some View {
        VStack(spacing: 10) {
            NavigationLink {
                MealBanksView()
            } label: {
                actionRow(emoji: "🍽",
                          title: "افتح بنك الوجبات",
                          subtitle: "أفكار جاهزة حسب وقت اليوم")
            }
            .buttonStyle(.plain)

            NavigationLink {
                GuideGoldenRulesView()
            } label: {
                actionRow(emoji: "📖",
                          title: "اقرأ القواعد الذهبية",
                          subtitle: "ست قواعد تُبقي النظام واضحاً")
            }
            .buttonStyle(.plain)

            Button {
                showCapture = true
            } label: {
                actionRow(emoji: "📸",
                          title: "صوّر ما أمامك",
                          subtitle: "نحلّل وجبتك ونعطيك الإشارة")
            }
            .buttonStyle(.plain)
        }
    }

    private func actionRow(emoji: String, title: String, subtitle: String) -> some View {
        CardContainer {
            HStack(spacing: 14) {
                Text(emoji).font(.system(size: 28))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.cardTitle.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.forward")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.textSecondary)
            }
        }
    }
}
