import SwiftUI
import SwiftData

/// نقطة التفرّع: إن لم يقبل المستخدم التنبيه الطبي بعد، نعرض الإعداد الأولي،
/// وإلا ننتقل إلى الواجهة الرئيسية.
struct RootView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [UserProfile]

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        Group {
            if let profile, profile.disclaimerAcceptedAt != nil {
                MainTabView(profile: profile)
            } else {
                OnboardingFlowView(existingProfile: profile)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}
