import SwiftUI
import SwiftData

struct MainTabView: View {
    let profile: UserProfile
    @Environment(\.modelContext) private var context

    var body: some View {
        TabView {
            TodayView(profile: profile)
                .tabItem { Label("اليوم", systemImage: "sun.max.fill") }

            HistoryView()
                .tabItem { Label("السجل", systemImage: "calendar") }

            GuideView()
                .tabItem { Label("الدليل", systemImage: "book.fill") }

            SettingsView(profile: profile)
                .tabItem { Label("الإعدادات", systemImage: "gearshape.fill") }
        }
        .tint(Theme.primary)
        .background(Theme.background)
        .onAppear {
            TipsService.seedIfNeeded(context: context)
            NotificationService.reschedule(profile: profile, context: context)
        }
    }
}
