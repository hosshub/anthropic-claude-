import SwiftUI

private struct BottomMarkerKey: PreferenceKey {
    static var defaultValue: CGFloat = .greatestFiniteMagnitude
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = min(value, nextValue())
    }
}

/// شاشة التنبيه الطبي — يجب تمريرها بالكامل قبل تفعيل زر الموافقة.
struct MedicalDisclaimerView: View {
    let onAccept: () -> Void
    var showAcceptButton: Bool = true

    @State private var reachedBottom = false

    private let disclaimerText = RulesService.shared.rules.medicalDisclaimer

    var body: some View {
        VStack(spacing: 0) {
            header

            GeometryReader { outer in
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("هذا النظام مثير للجدل ولم تعتمده الهيئات الطبية الرسمية. اقرأ بعناية قبل المتابعة.")
                            .font(.cardTitle)
                            .foregroundStyle(Theme.khabith)

                        Text(disclaimerText)
                            .arabicBody()

                        Text("ما لا يقدّمه هذا التطبيق:")
                            .font(.sectionTitle)
                            .foregroundStyle(Theme.textPrimary)
                            .padding(.top, 8)

                        bullet("لا يقدّم استشارة طبية أو تشخيصاً.")
                        bullet("لا يدّعي علاج أو شفاء أي مرض.")
                        bullet("لا يتناول موضوع الأدوية إطلاقاً؛ لا توقف دواءً موصوفاً لك.")
                        bullet("هو مجرد أداة لتتبع نظام غذائي اخترته أنت بمحض إرادتك.")

                        Text("استشر طبيبك أو أخصائي تغذية قبل اتباع أي نظام غذائي، خاصةً إن كنت تعاني مرضاً مزمناً، أو كنت حاملاً أو مرضعاً، أو كان عمرك أقل من 18 سنة.")
                            .arabicBody()
                            .padding(.top, 4)

                        Color.clear
                            .frame(height: 1)
                            .background(GeometryReader { g in
                                Color.clear.preference(
                                    key: BottomMarkerKey.self,
                                    value: g.frame(in: .named("discScroll")).minY
                                )
                            })
                    }
                    .padding(20)
                }
                .coordinateSpace(name: "discScroll")
                .onPreferenceChange(BottomMarkerKey.self) { minY in
                    if minY < outer.size.height + 40 { reachedBottom = true }
                }
            }

            if showAcceptButton {
                VStack(spacing: 8) {
                    if !reachedBottom {
                        Label("مرّر للأسفل لقراءة التنبيه كاملاً", systemImage: "arrow.down")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    PrimaryButton(
                        title: "أوافق وأتحمل المسؤولية",
                        systemImage: "checkmark",
                        isEnabled: reachedBottom,
                        action: onAccept
                    )
                }
                .padding(20)
                .background(Theme.surface)
            }
        }
        .background(Theme.background)
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: "info.circle.fill")
            Text("تنبيه طبي")
                .font(.screenTitle)
            Spacer()
        }
        .foregroundStyle(.white)
        .padding()
        .background(Theme.khabith)
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "circle.fill").font(.system(size: 6)).padding(.top, 7)
            Text(text).arabicBody()
        }
    }
}
