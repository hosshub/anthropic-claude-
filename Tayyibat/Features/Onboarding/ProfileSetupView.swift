import SwiftUI

struct ProfileSetupView: View {
    @Binding var name: String
    @Binding var ageText: String
    @Binding var goal: UserGoal
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("ملفك الشخصي")
                        .font(.screenTitle)
                        .foregroundStyle(Theme.textPrimary)

                    field(title: "الاسم") {
                        TextField("اكتب اسمك", text: $name)
                            .textFieldStyle(.roundedBorder)
                    }

                    field(title: "العمر (اختياري)") {
                        TextField("العمر", text: $ageText)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                    }

                    field(title: "هدفك") {
                        Picker("الهدف", selection: $goal) {
                            ForEach(UserGoal.allCases, id: \.self) { g in
                                Text(g.labelAr).tag(g)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .padding(20)
            }
            PrimaryButton(
                title: "متابعة",
                systemImage: "arrow.left",
                isEnabled: !name.trimmingCharacters(in: .whitespaces).isEmpty,
                action: onContinue
            )
            .padding(20)
        }
        .background(Theme.background)
    }

    private func field<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.cardTitle).foregroundStyle(Theme.textPrimary)
            content()
        }
    }
}
