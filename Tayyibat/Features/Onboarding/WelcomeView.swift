import SwiftUI

struct WelcomeView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image("BrandLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
                .shadow(color: Theme.cardShadow, radius: 12, y: 6)
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
