import SwiftUI
import SwiftData

struct NotificationSettingsView: View {
    @Bindable var profile: UserProfile
    @Environment(\.modelContext) private var context

    private let hourOptions: [(label: String, hour: Int)] = [
        ("الصباح ١١ص", 11), ("الظهر ٢م", 14), ("العصر ٤م", 16), ("المساء ٨م", 20)
    ]

    var body: some View {
        Form {
            Section {
                Toggle("تفعيل الإشعارات", isOn: masterBinding)
                    .tint(Theme.primary)
            } footer: {
                Text("جميع الإشعارات اختيارية وتُجدول محلياً على جهازك.")
            }

            if profile.notificationsEnabled {
                Section("الأنواع") {
                    toggle("تذكيرات الوجبات المرنة", \.mealRemindersEnabled)
                    toggle("نصائح يومية", \.tipsEnabled)
                    toggle("تذكيرات الصيام", \.fastingRemindersEnabled)
                    toggle("تذكير مراجعة اليوم", \.logRemindersEnabled)
                }

                if profile.tipsEnabled {
                    Section("شدّة النصائح") {
                        Picker("الشدّة", selection: intensityBinding) {
                            ForEach(NotificationIntensity.allCases, id: \.self) { i in
                                Text("\(i.labelAr) (\(i.dailyTipCount)/يوم)").tag(i)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }

                if profile.mealRemindersEnabled {
                    Section("أوقات تذكير الوجبات") {
                        ForEach(hourOptions, id: \.hour) { option in
                            Toggle(option.label, isOn: reminderHourBinding(option.hour))
                                .tint(Theme.primary)
                        }
                    }
                }

                Section("لا تزعج") {
                    DatePicker("من", selection: quietBinding(\.quietHoursStart), displayedComponents: .hourAndMinute)
                    DatePicker("إلى", selection: quietBinding(\.quietHoursEnd), displayedComponents: .hourAndMinute)
                }
            }
        }
        .navigationTitle("الإشعارات")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Bindings that persist + reschedule on change

    private var masterBinding: Binding<Bool> {
        Binding(
            get: { profile.notificationsEnabled },
            set: { newValue in
                if newValue {
                    Task {
                        let granted = await NotificationService.requestAuthorization()
                        await MainActor.run {
                            profile.notificationsEnabled = granted
                            applyChanges()
                        }
                    }
                } else {
                    profile.notificationsEnabled = false
                    applyChanges()
                }
            }
        )
    }

    private func toggle(_ title: String, _ keyPath: ReferenceWritableKeyPath<UserProfile, Bool>) -> some View {
        Toggle(title, isOn: Binding(
            get: { profile[keyPath: keyPath] },
            set: { profile[keyPath: keyPath] = $0; applyChanges() }
        ))
        .tint(Theme.primary)
    }

    private var intensityBinding: Binding<NotificationIntensity> {
        Binding(
            get: { profile.dailyTipsIntensity },
            set: { profile.dailyTipsIntensity = $0; applyChanges() }
        )
    }

    private func quietBinding(_ keyPath: ReferenceWritableKeyPath<UserProfile, Date>) -> Binding<Date> {
        Binding(
            get: { profile[keyPath: keyPath] },
            set: { profile[keyPath: keyPath] = $0; applyChanges() }
        )
    }

    private func reminderHourBinding(_ hour: Int) -> Binding<Bool> {
        Binding(
            get: { profile.reminderHours.contains(hour) },
            set: { on in
                var hours = Set(profile.reminderHours)
                if on { hours.insert(hour) } else { hours.remove(hour) }
                profile.reminderHours = hours.sorted()
                applyChanges()
            }
        )
    }

    private func applyChanges() {
        try? context.save()
        NotificationService.reschedule(profile: profile, context: context)
    }
}
