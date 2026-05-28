import SwiftUI

struct APIKeySettingsView: View {
    @State private var keyInput = ""
    @State private var hasKey = KeychainService.hasAPIKey
    @State private var saved = false

    var body: some View {
        Form {
            Section {
                if hasKey {
                    Label("مفتاح API محفوظ", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(Theme.primary)
                } else {
                    Label("لا يوجد مفتاح محفوظ", systemImage: "exclamationmark.circle")
                        .foregroundStyle(Theme.khabith)
                }
            }

            Section("إدخال المفتاح") {
                SecureField("sk-ant-...", text: $keyInput)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                Button("حفظ المفتاح") {
                    let trimmed = keyInput.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    KeychainService.saveAPIKey(trimmed)
                    keyInput = ""
                    hasKey = true
                    saved = true
                }
                .disabled(keyInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            if hasKey {
                Section {
                    Button("حذف المفتاح", role: .destructive) {
                        KeychainService.deleteAPIKey()
                        hasKey = false
                    }
                }
            }

            Section {
                Text("يُخزَّن المفتاح بأمان في Keychain على جهازك فقط، ولا يُرسل لأي خادم غير Anthropic أثناء تحليل الصور.")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .navigationTitle("مفتاح Claude API")
        .navigationBarTitleDisplayMode(.inline)
        .alert("تم الحفظ", isPresented: $saved) {
            Button("حسناً", role: .cancel) {}
        }
    }
}
