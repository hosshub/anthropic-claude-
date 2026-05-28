import SwiftUI
import SwiftData

/// نقطة التفرّع: إن لم يقبل المستخدم التنبيه الطبي بعد، نعرض الإعداد الأولي،
/// وإلا ننتقل إلى الواجهة الرئيسية.
struct RootView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [UserProfile]
    @EnvironmentObject private var auth: AuthService
    @State private var didAttemptRestore = false

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        Group {
            if AppConfig.authEnabled && !auth.isAuthenticated && !didAttemptRestore {
                // أثناء محاولة استعادة الجلسة المحفوظة — نتجنّب وميض شاشة الدخول.
                ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Theme.background.ignoresSafeArea())
            } else if AppConfig.authEnabled && !auth.isAuthenticated {
                AuthView()
            } else if let profile, profile.disclaimerAcceptedAt != nil {
                MainTabView(profile: profile)
            } else {
                OnboardingFlowView(existingProfile: profile)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .task {
            guard AppConfig.authEnabled, !didAttemptRestore else { return }
            await auth.restoreIfPossible()
            didAttemptRestore = true
        }
    }
}
