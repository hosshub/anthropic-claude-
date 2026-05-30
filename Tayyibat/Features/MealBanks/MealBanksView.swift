import SwiftUI

/// شاشة بنوك الوجبات (تفاعليّة). تُستخدم من تبويب الدليل ومن مساعد "عندما تحتار".
struct MealBanksView: View {
    @State private var selectedItem: MealBankItem?
    @State private var showCapture = false

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                CardContainer {
                    HStack(spacing: 10) {
                        Image(systemName: "tray.full.fill").foregroundStyle(Theme.primary)
                        Text("أفكار وجبات مرتّبة حسب الوقت — اختر فكرة، اقرأ التفاصيل، ثم صوّرها لتُسجَّل.")
                            .font(.bodyText)
                            .foregroundStyle(Theme.textPrimary)
                            .lineSpacing(4)
                    }
                }
                ForEach(MealBanksData.banks) { bank in
                    bankCard(bank)
                }
                MedicalDisclaimerFooter()
                    .padding(.top, 4)
            }
            .padding(16)
        }
        .background(Theme.background)
        .navigationTitle("بنك الوجبات")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedItem) { item in
            MealBankItemDetailSheet(item: item) {
                selectedItem = nil
                showCapture = true
            }
            .presentationDetents([.medium, .large])
        }
        .fullScreenCover(isPresented: $showCapture) {
            CaptureFlowView()
        }
    }

    private func bankCard(_ bank: MealBank) -> some View {
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
                Divider()
                VStack(spacing: 8) {
                    ForEach(bank.items) { item in
                        Button { selectedItem = item } label: {
                            itemRow(item)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func itemRow(_ item: MealBankItem) -> some View {
        HStack(spacing: 10) {
            Circle().fill(item.zone.color).frame(width: 9, height: 9)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.nameAr)
                    .font(.bodyText.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.leading)
                Text(item.compositionAr)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
            Spacer()
            Image(systemName: "info.circle")
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(.vertical, 4)
    }
}

/// تفاصيل عنصر بنك (يفتح كـ Sheet).
struct MealBankItemDetailSheet: View {
    let item: MealBankItem
    let onCapture: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Circle().fill(item.zone.color).frame(width: 14, height: 14)
                        Text(item.zone.labelAr)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(item.zone.color)
                        Spacer()
                    }
                    Text(item.nameAr)
                        .font(.displayTitle)
                        .foregroundStyle(Theme.textPrimary)

                    CardContainer {
                        VStack(alignment: .leading, spacing: 6) {
                            Label("التكوين", systemImage: "list.bullet")
                                .font(.cardTitle.weight(.semibold))
                                .foregroundStyle(Theme.primary)
                            Text(item.compositionAr)
                                .font(.bodyText)
                                .foregroundStyle(Theme.textPrimary)
                                .lineSpacing(5)
                        }
                    }

                    if let note = item.noteAr {
                        CardContainer {
                            VStack(alignment: .leading, spacing: 6) {
                                Label("ملاحظة", systemImage: "info.circle")
                                    .font(.cardTitle.weight(.semibold))
                                    .foregroundStyle(item.zone == .yellow ? Theme.gold : Theme.primary)
                                Text(note)
                                    .font(.bodyText)
                                    .foregroundStyle(Theme.textPrimary)
                                    .lineSpacing(5)
                            }
                        }
                    }

                    PrimaryButton(title: "صوّر هذه الوجبة",
                                  systemImage: "camera.fill",
                                  action: onCapture)
                        .padding(.top, 4)
                }
                .padding(20)
            }
            .background(Theme.background)
            .navigationTitle("تفاصيل الوجبة")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("إغلاق") { dismiss() }
                }
            }
        }
    }
}
