import Foundation
import AuthenticationServices
import CryptoKit
import UIKit

/// مصادقة المستخدم عبر Supabase (GoTrue) باستخدام REST مباشرةً — دون أي مكتبة خارجية.
/// - Apple: عبر Sign in with Apple الأصلي ثم تبادل id_token.
/// - Google (وغيره): عبر ASWebAuthenticationSession مع PKCE.
@MainActor
final class AuthService: ObservableObject {
    @Published private(set) var isAuthenticated = false
    @Published private(set) var userEmail: String?
    @Published private(set) var isWorking = false
    @Published var lastError: String?

    private var accessToken: String?
    private var refreshToken: String?
    private var webSession: ASWebAuthenticationSession?
    private let anchorProvider = AnchorProvider()

    var isEnabled: Bool { AppConfig.authEnabled }

    // MARK: - استعادة الجلسة عند الإقلاع

    func restoreIfPossible() async {
        guard isEnabled, let stored = AuthSessionStore.load() else { return }
        refreshToken = stored.refreshToken
        userEmail = stored.email
        let ok = await postToken(path: "token?grant_type=refresh_token",
                                 body: ["refresh_token": stored.refreshToken])
        if !ok { signOut() }
    }

    // MARK: - Apple

    func completeAppleSignIn(idToken: String, rawNonce: String) async {
        await postToken(path: "token?grant_type=id_token",
                        body: ["provider": "apple", "id_token": idToken, "nonce": rawNonce])
    }

    // MARK: - Google / OAuth عبر المتصفح + PKCE

    func signInWithGoogle() async { await signInWithOAuth(provider: "google") }

    func signInWithOAuth(provider: String) async {
        guard isEnabled else { lastError = "لم تُضبط مصادقة Supabase بعد."; return }
        let verifier = Self.randomURLSafe(64)
        let challenge = Self.codeChallenge(for: verifier)
        var comps = URLComponents(string: "\(AppConfig.supabaseURL)/auth/v1/authorize")
        comps?.queryItems = [
            URLQueryItem(name: "provider", value: provider),
            URLQueryItem(name: "redirect_to", value: AppConfig.authRedirectURL),
            URLQueryItem(name: "code_challenge", value: challenge),
            URLQueryItem(name: "code_challenge_method", value: "s256")
        ]
        guard let url = comps?.url else { lastError = "رابط غير صالح."; return }

        let callback: URL? = await withCheckedContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: AppConfig.authRedirectScheme
            ) { callbackURL, _ in
                continuation.resume(returning: callbackURL)
            }
            session.presentationContextProvider = anchorProvider
            session.prefersEphemeralWebBrowserSession = false
            webSession = session
            session.start()
        }
        webSession = nil
        guard let callback else { lastError = "أُلغي تسجيل الدخول."; return }
        await handleOAuthCallback(callback, verifier: verifier)
    }

    private func handleOAuthCallback(_ url: URL, verifier: String) async {
        let comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
        if let code = comps?.queryItems?.first(where: { $0.name == "code" })?.value {
            await postToken(path: "token?grant_type=pkce",
                            body: ["auth_code": code, "code_verifier": verifier])
            return
        }
        if let fragment = comps?.fragment {
            let pairs = Self.parsePairs(fragment)
            if let access = pairs["access_token"], let refresh = pairs["refresh_token"] {
                setSession(access: access, refresh: refresh, email: nil)
                await fetchUser()
                return
            }
            if let desc = pairs["error_description"] {
                lastError = desc.replacingOccurrences(of: "+", with: " ")
                return
            }
        }
        lastError = "تعذّر إتمام تسجيل الدخول."
    }

    // MARK: - بيانات المستخدم

    private func fetchUser() async {
        guard let token = accessToken,
              let url = URL(string: "\(AppConfig.supabaseURL)/auth/v1/user") else { return }
        var req = URLRequest(url: url)
        req.setValue(AppConfig.supabaseAnonKey, forHTTPHeaderField: "apikey")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        guard let (data, resp) = try? await URLSession.shared.data(for: req),
              (resp as? HTTPURLResponse)?.statusCode == 200,
              let user = try? JSONDecoder().decode(SBUser.self, from: data) else { return }
        userEmail = user.email
        if var stored = AuthSessionStore.load() {
            stored.email = user.email
            AuthSessionStore.save(stored)
        }
    }

    // MARK: - تسجيل الخروج

    func signOut() {
        accessToken = nil
        refreshToken = nil
        userEmail = nil
        isAuthenticated = false
        lastError = nil
        AuthSessionStore.clear()
    }

    func setError(_ message: String) { lastError = message }

    // MARK: - نقطة token

    @discardableResult
    private func postToken(path: String, body: [String: Any]) async -> Bool {
        guard let url = URL(string: "\(AppConfig.supabaseURL)/auth/v1/\(path)") else {
            lastError = "إعداد Supabase غير صالح."
            return false
        }
        isWorking = true
        defer { isWorking = false }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue(AppConfig.supabaseAnonKey, forHTTPHeaderField: "apikey")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                lastError = Self.errorMessage(from: data) ?? "تعذّر تسجيل الدخول."
                return false
            }
            let tr = try JSONDecoder().decode(TokenResponse.self, from: data)
            setSession(access: tr.access_token, refresh: tr.refresh_token, email: tr.user?.email)
            return true
        } catch {
            lastError = "تعذّر الاتصال: \(error.localizedDescription)"
            return false
        }
    }

    private func setSession(access: String, refresh: String, email: String?) {
        accessToken = access
        refreshToken = refresh
        if let email { userEmail = email }
        AuthSessionStore.save(StoredSession(accessToken: access,
                                            refreshToken: refresh,
                                            email: email ?? userEmail))
        isAuthenticated = true
        lastError = nil
    }

    // MARK: - نماذج الاستجابة

    private struct TokenResponse: Decodable {
        let access_token: String
        let refresh_token: String
        let user: SBUser?
    }
    private struct SBUser: Decodable { let email: String? }

    private static func errorMessage(from data: Data) -> String? {
        guard let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        return (obj["error_description"] as? String)
            ?? (obj["msg"] as? String)
            ?? (obj["error"] as? String)
            ?? (obj["message"] as? String)
    }

    private static func parsePairs(_ fragment: String) -> [String: String] {
        var dict: [String: String] = [:]
        for part in fragment.split(separator: "&") {
            let kv = part.split(separator: "=", maxSplits: 1).map(String.init)
            if kv.count == 2 { dict[kv[0]] = kv[1].removingPercentEncoding ?? kv[1] }
        }
        return dict
    }

    // MARK: - PKCE / nonce

    static func randomURLSafe(_ count: Int) -> String {
        var bytes = [UInt8](repeating: 0, count: count)
        _ = SecRandomCopyBytes(kSecRandomDefault, count, &bytes)
        return Data(bytes).base64URLEncoded()
    }

    static func codeChallenge(for verifier: String) -> String {
        Data(SHA256.hash(data: Data(verifier.utf8))).base64URLEncoded()
    }

    static func randomNonce(_ length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remaining = length
        while remaining > 0 {
            var random: UInt8 = 0
            guard SecRandomCopyBytes(kSecRandomDefault, 1, &random) == errSecSuccess else { continue }
            if Int(random) < charset.count {
                result.append(charset[Int(random)])
                remaining -= 1
            }
        }
        return result
    }

    static func sha256Hex(_ input: String) -> String {
        SHA256.hash(data: Data(input.utf8)).map { String(format: "%02x", $0) }.joined()
    }
}

private extension Data {
    func base64URLEncoded() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

/// يوفّر نافذة العرض لـ ASWebAuthenticationSession.
private final class AnchorProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let window = scenes.flatMap { $0.windows }.first { $0.isKeyWindow }
            ?? scenes.first?.windows.first
        return window ?? ASPresentationAnchor()
    }
}
