import SwiftUI
import SwiftData

@main
struct TayyibatApp: App {
    let modelContainer: ModelContainer
    @StateObject private var auth = AuthService()

    init() {
        do {
            modelContainer = try ModelContainer(
                for: Meal.self, FoodItem.self, FastingDay.self,
                DailySummary.self, UserProfile.self, NotificationTip.self
            )
        } catch {
            fatalError("تعذّر إنشاء حاوية البيانات: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(auth)
                .environment(\.locale, Locale(identifier: "ar"))
                .environment(\.layoutDirection, .rightToLeft)
                .tint(Theme.primary)
        }
        .modelContainer(modelContainer)
    }
}
