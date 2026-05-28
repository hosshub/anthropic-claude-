import SwiftUI
import AuthenticationServices

/// شاشة تسجيل الدخول (تظهر فقط عند تفعيل المصادقة بوضع المفتاح العام في AppConfig).
struct AuthView: View {
    @EnvironmentObject private var auth: AuthService
    @State private var currentNonce: String?

    var body: some View {
        VStack(spacing: 22) {
            Spacer()

            Image("BrandLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 130, height: 130)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(color: Theme.cardShadow, radius: 12, y: 6)

            Text("الطيبات")
                .font(.displayTitle)
                .foregroundStyle(Theme.textPrimary)

            Text("سجّل الدخول للمتابعة")
                .font(.bodyText)
                .foregroundStyle(Theme.textSecondary)

            Spacer()

            VStack(spacing: 14) {
                Button {
                    Task { await auth.signInWithGoogle() }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "globe")
                        Text("المتابعة عبر Google").fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity, minHeight: 50)
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.primary)
                .disabled(auth.isWorking)

                if AppConfig.appleSignInEnabled {
                    SignInWithAppleButton(.signIn) { request in
                        let nonce = AuthService.randomNonce()
                        currentNonce = nonce
                        request.requestedScopes = [.fullName, .email]
                        request.nonce = AuthService.sha256Hex(nonce)
                    } onCompletion: { result in
                        handleApple(result)
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .disabled(auth.isWorking)
                }
            }
            .padding(.horizontal, 28)

            if auth.isWorking {
                ProgressView().padding(.top, 4)
            }

            if let error = auth.lastError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(Theme.khabith)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
            }

            Text("بالمتابعة فإنك توافق على سياسة الخصوصية الخاصة بالتطبيق.")
                .font(.caption2)
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.textSecondary)
                .padding(.horizontal, 28)
                .padding(.bottom, 10)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background.ignoresSafeArea())
    }

    private func handleApple(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = credential.identityToken,
                  let idToken = String(data: tokenData, encoding: .utf8),
                  let nonce = currentNonce else {
                auth.setError("تعذّر الحصول على بيانات Apple.")
                return
            }
            Task { await auth.completeAppleSignIn(idToken: idToken, rawNonce: nonce) }
        case .failure(let error):
            auth.setError(error.localizedDescription)
        }
    }
}
