import SwiftUI

struct NotificationPermissionView: View {
    /// يُبلّغ بالنتيجة: هل مُنحت الصلاحية، وأوقات التذكير المختارة.
    let onFinish: (_ granted: Bool, _ reminderHours: [Int]) -> Void

    @State private var reminderHours: Set<Int> = [11, 16, 20]
    @State private var requesting = false

    private let hourOptions: [(label: String, hour: Int)] = [
        ("الصباح ١١ص", 11), ("الظهر ٢م", 14), ("العصر ٤م", 16), ("المساء ٨م", 20)
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(Theme.gold)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 12)

                    Text("التذكيرات والنصائح")
                        .font(.screenTitle)
                        .foregroundStyle(Theme.textPrimary)

                    Text("نرسل تذكيرات مرنة ونصائح يومية لمساعدتك على الالتزام — كلها اختيارية ويمكنك تعديلها لاحقاً من الإعدادات.")
                        .arabicBody()
                        .foregroundStyle(Theme.textSecondary)

                    Text("أوقات التذكير المفضّلة")
                        .font(.cardTitle)
                        .foregroundStyle(Theme.textPrimary)

                    ForEach(hourOptions, id: \.hour) { option in
                        Toggle(option.label, isOn: Binding(
                            get: { reminderHours.contains(option.hour) },
                            set: { on in
                                if on { reminderHours.insert(option.hour) }
                                else { reminderHours.remove(option.hour) }
                            }
                        ))
                        .tint(Theme.primary)
                    }
                }
                .padding(20)
            }

            VStack(spacing: 10) {
                PrimaryButton(title: "تفعيل الإشعارات", systemImage: "bell.fill") {
                    Task { await complete(request: true) }
                }
                Button("ليس الآن") { Task { await complete(request: false) } }
                    .font(.bodyText)
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(20)
            .disabled(requesting)
        }
        .background(Theme.background)
    }

    private func complete(request: Bool) async {
        requesting = true
        let granted = request ? await NotificationService.requestAuthorization() : false
        requesting = false
        onFinish(granted, reminderHours.sorted())
    }
}
