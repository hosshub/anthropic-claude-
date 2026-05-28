import SwiftUI
import SwiftData

private enum OnboardingStep: Int, CaseIterable {
    case welcome, disclaimer, philosophy, profile, notifications
}

struct OnboardingFlowView: View {
    let existingProfile: UserProfile?
    @Environment(\.modelContext) private var context

    @State private var step: OnboardingStep = .welcome
    @State private var name = ""
    @State private var ageText = ""
    @State private var goal: UserGoal = .adherence

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            content
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
                .id(step)
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: step)
    }

    @ViewBuilder
    private var content: some View {
        switch step {
        case .welcome:
            WelcomeView { advance() }
        case .disclaimer:
            MedicalDisclaimerView(onAccept: { advance() })
        case .philosophy:
            PhilosophyView { advance() }
        case .profile:
            ProfileSetupView(name: name, ageText: ageText, goal: goal) { newName, newAge, newGoal in
                name = newName
                ageText = newAge
                goal = newGoal
                advance()
            }
        case .notifications:
            NotificationPermissionView { granted, hours in
                finish(notificationsEnabled: granted, reminderHours: hours)
            }
        }
    }

    private func advance() {
        if let next = OnboardingStep(rawValue: step.rawValue + 1) {
            step = next
        }
    }

    private func finish(notificationsEnabled: Bool, reminderHours: [Int]) {
        let profile = existingProfile ?? UserProfile()
        profile.name = name.trimmingCharacters(in: .whitespaces)
        profile.age = Int(ageText)
        profile.goal = goal
        profile.notificationsEnabled = notificationsEnabled
        profile.reminderHours = reminderHours
        profile.disclaimerAcceptedAt = .now
        if existingProfile == nil {
            context.insert(profile)
        }
        try? context.save()
        // RootView يلتقط التغيير عبر @Query وينتقل للواجهة الرئيسية.
    }
}
