import Foundation
import SwiftData
import UserNotifications

/// يدير صلاحيات وجدولة الإشعارات المحلية (تذكيرات + نصائح + صيام + سجل).
enum NotificationService {
    private static var center: UNUserNotificationCenter { .current() }

    // MARK: - Authorization

    static func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    // MARK: - Scheduling

    /// يلغي كل الإشعارات المعلّقة ويعيد جدولتها وفق تفضيلات المستخدم.
    static func reschedule(profile: UserProfile, context: ModelContext) {
        center.removeAllPendingNotificationRequests()
        guard profile.notificationsEnabled else { return }

        if profile.mealRemindersEnabled { scheduleMealReminders(profile: profile) }
        if profile.tipsEnabled { scheduleTips(profile: profile, context: context) }
        if profile.fastingRemindersEnabled { scheduleFastingReminders(profile: profile) }
        if profile.logRemindersEnabled { scheduleLogReminder(profile: profile) }
    }

    // MARK: - Meal reminders (تذكير مرن يومي متكرر)

    private static func scheduleMealReminders(profile: UserProfile) {
        for hour in profile.reminderHours where !isInQuietHours(hour: hour, profile: profile) {
            scheduleDailyRepeating(
                id: "meal_\(hour)",
                hour: hour,
                minute: 0,
                title: "الطيبات",
                body: "هل تشعر بجوع حقيقي الآن؟ إن كان كذلك، تذكّر أن تختار من الطيبات 🍽️"
            )
        }
    }

    // MARK: - Tips (نصائح متناوبة على مدى الأيام القادمة)

    private static func scheduleTips(profile: UserProfile, context: ModelContext) {
        let slots = tipSlots(for: profile.dailyTipsIntensity)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        for dayOffset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
            for (index, slot) in slots.enumerated() {
                guard !isInQuietHours(hour: slot.hour, profile: profile) else { continue }
                guard let fireDate = calendar.date(bySettingHour: slot.hour, minute: 0, second: 0, of: day),
                      fireDate > .now else { continue }
                guard let tip = TipsService.nextTip(for: slot.category, context: context) else { continue }
                scheduleOneShot(
                    id: "tip_\(dayOffset)_\(index)",
                    date: fireDate,
                    title: "نصيحة الطيبات",
                    body: tip
                )
            }
        }
    }

    private static func tipSlots(for intensity: NotificationIntensity) -> [(hour: Int, category: TipCategory)] {
        switch intensity {
        case .low:
            return [(9, .morning)]
        case .medium:
            return [(9, .morning), (14, .afternoon), (19, .evening)]
        case .high:
            return [(8, .morning), (11, .morning), (14, .afternoon), (17, .evening), (20, .evening)]
        }
    }

    // MARK: - Fasting reminders (ليلة ما قبل يوم الصيام)

    private static func scheduleFastingReminders(profile: UserProfile) {
        let calendar = Calendar.current
        let upcoming = FastingCalculator.upcomingFastingDays(days: 14)
        for (index, entry) in upcoming.enumerated() {
            guard let eveningBefore = calendar.date(byAdding: .day, value: -1, to: entry.date),
                  let fireDate = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: eveningBefore),
                  fireDate > .now else { continue }
            let names = entry.types.map(\.labelAr).joined(separator: " و")
            scheduleOneShot(
                id: "fast_\(index)",
                date: fireDate,
                title: "تذكير الصيام",
                body: "غداً \(names) — هل تنوي الصيام؟ 🌙"
            )
        }
    }

    // MARK: - Log reminder (نهاية اليوم)

    private static func scheduleLogReminder(profile: UserProfile) {
        guard !isInQuietHours(hour: 21, profile: profile) else { return }
        scheduleDailyRepeating(
            id: "log_review",
            hour: 21,
            minute: 0,
            title: "ملخص يومك",
            body: "كيف كان يومك مع الطيبات؟ راجع ملخصك وسجّل ما فاتك 📝"
        )
    }

    // MARK: - Primitives

    private static func scheduleDailyRepeating(id: String, hour: Int, minute: Int, title: String, body: String) {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        add(id: id, title: title, body: body, trigger: trigger)
    }

    private static func scheduleOneShot(id: String, date: Date, title: String, body: String) {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        add(id: id, title: title, body: body, trigger: trigger)
    }

    private static func add(id: String, title: String, body: String, trigger: UNNotificationTrigger) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Quiet hours

    /// هل الساعة تقع ضمن فترة "لا تزعج"؟ يدعم الالتفاف عبر منتصف الليل.
    static func isInQuietHours(hour: Int, profile: UserProfile) -> Bool {
        let cal = Calendar.current
        let start = cal.component(.hour, from: profile.quietHoursStart)
        let end = cal.component(.hour, from: profile.quietHoursEnd)
        if start == end { return false }
        if start < end {
            return hour >= start && hour < end
        } else {
            // يلتف عبر منتصف الليل (مثلاً 23 -> 7)
            return hour >= start || hour < end
        }
    }
}
