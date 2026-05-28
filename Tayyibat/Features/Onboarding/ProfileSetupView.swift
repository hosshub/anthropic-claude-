import SwiftUI

struct ProfileSetupView: View {
    @Binding var name: String
    @Binding var ageText: String
    @Binding var goal: UserGoal
    let onContinue: () -> Void

    @FocusState private var focusedField: Field?
    private enum Field { case name, age }

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
                            .focused($focusedField, equals: .name)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .age }
                    }

                    field(title: "العمر (اختياري)") {
                        TextField("العمر", text: $ageText)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .focused($focusedField, equals: .age)
                            .onChange(of: ageText) { _, newValue in
                                let digits = newValue.filter(\.isNumber)
                                if digits != newValue { ageText = digits }
                            }
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
            .scrollDismissesKeyboard(.interactively)

            PrimaryButton(
                title: "متابعة",
                systemImage: "arrow.left",
                isEnabled: !name.trimmingCharacters(in: .whitespaces).isEmpty,
                action: {
                    focusedField = nil
                    onContinue()
                }
            )
            .padding(20)
        }
        .background(Theme.background)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("تم") { focusedField = nil }
            }
        }
    }

    private func field<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.cardTitle).foregroundStyle(Theme.textPrimary)
            content()
        }
    }
}
