import SwiftUI

struct WelcomeView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "leaf.circle.fill")
                .font(.system(size: 90))
                .foregroundStyle(Theme.primary)
            Text("الطيبات")
                .font(.displayTitle)
                .foregroundStyle(Theme.textPrimary)
            Text("رفيقك لتتبع الالتزام بنظام الطيبات الغذائي — صوّر وجبتك واعرف مدى توافقها.")
                .font(.bodyText)
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.textSecondary)
                .lineSpacing(6)
                .padding(.horizontal, 32)
            Spacer()
            PrimaryButton(title: "ابدأ", systemImage: "arrow.left", action: onContinue)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
        }
    }
}
