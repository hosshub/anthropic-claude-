import SwiftUI
import AuthenticationServices

/// شاشة الدخول/التسجيل (تظهر فقط عند تفعيل المصادقة بوضع المفتاح العام في AppConfig).
struct AuthView: View {
    @EnvironmentObject private var auth: AuthService

    enum Mode: Hashable {
        case signIn, signUp
        var cta: String { self == .signIn ? "تسجيل الدخول" : "إنشاء الحساب" }
    }

    @State private var mode: Mode = .signIn
    @State private var email = ""
    @State private var password = ""
    @State private var currentNonce: String?

    private var canSubmit: Bool {
        !auth.isWorking && email.contains("@") && password.count >= 6
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Image("BrandLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 96, height: 96)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: Theme.cardShadow, radius: 10, y: 5)
                    .padding(.top, 24)

                Text("الطيبات")
                    .font(.displayTitle)
                    .foregroundStyle(Theme.textPrimary)
                Text(mode == .signIn ? "سجّل الدخول للمتابعة" : "أنشئ حساباً للبدء")
                    .font(.bodyText)
                    .foregroundStyle(Theme.textSecondary)

                Picker("", selection: $mode) {
                    Text("تسجيل الدخول").tag(Mode.signIn)
                    Text("حساب جديد").tag(Mode.signUp)
                }
                .pickerStyle(.segmented)
                .padding(.top, 4)

                VStack(spacing: 12) {
                    TextField("البريد الإلكتروني", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    SecureField("كلمة المرور (٦ أحرف فأكثر)", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(mode == .signIn ? .password : .newPassword)

                    Button {
                        Task { await submit() }
                    } label: {
                        Text(mode.cta)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, minHeight: 48)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.primary)
                    .disabled(!canSubmit)
                }

                HStack {
                    Rectangle().fill(Theme.textSecondary.opacity(0.3)).frame(height: 1)
                    Text("أو").font(.caption).foregroundStyle(Theme.textSecondary)
                    Rectangle().fill(Theme.textSecondary.opacity(0.3)).frame(height: 1)
                }
                .padding(.vertical, 2)

                Button {
                    Task { await auth.signInWithGoogle() }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "globe")
                        Text("المتابعة عبر Google").fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity, minHeight: 48)
                }
                .buttonStyle(.bordered)
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
                    .frame(height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .disabled(auth.isWorking)
                }

                if auth.isWorking {
                    ProgressView().padding(.top, 4)
                }
                if let info = auth.infoMessage {
                    Text(info)
                        .font(.caption)
                        .foregroundStyle(Theme.primary)
                        .multilineTextAlignment(.center)
                }
                if let error = auth.lastError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(Theme.khabith)
                        .multilineTextAlignment(.center)
                }

                Text("بالمتابعة فإنك توافق على سياسة الخصوصية الخاصة بالتطبيق.")
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.bottom, 24)
            }
            .padding(.horizontal, 28)
            .frame(maxWidth: 460)
            .frame(maxWidth: .infinity)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Theme.background.ignoresSafeArea())
        .onChange(of: mode) { _, _ in
            auth.lastError = nil
            auth.infoMessage = nil
        }
    }

    private func submit() async {
        switch mode {
        case .signIn: await auth.signIn(email: email, password: password)
        case .signUp: await auth.signUp(email: email, password: password)
        }
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
