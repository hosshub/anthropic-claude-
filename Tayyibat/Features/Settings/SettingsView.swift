import SwiftUI
import UIKit
import SwiftData

struct SettingsView: View {
    @Bindable var profile: UserProfile
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var auth: AuthService

    @AppStorage("preferredLanguage") private var preferredLanguage = "ar"
    @State private var shareURL: URL?
    @State private var showShare = false
    @State private var showDeleteConfirm = false

    var body: some View {
        NavigationStack {
            Form {
                Section("الملف الشخصي") {
                    TextField("الاسم", text: $profile.name)
                    Picker("الهدف", selection: Binding(
                        get: { profile.goal },
                        set: { profile.goal = $0; try? context.save() }
                    )) {
                        ForEach(UserGoal.allCases, id: \.self) { Text($0.labelAr).tag($0) }
                    }
                }

                Section("النظام") {
                    if !AppConfig.usesProxy {
                        NavigationLink {
                            APIKeySettingsView()
                        } label: { Label("مفتاح Claude API", systemImage: "key.fill") }
                    }

                    NavigationLink {
                        NotificationSettingsView(profile: profile)
                    } label: { Label("الإشعارات", systemImage: "bell.fill") }
                }

                Section {
                    Picker("اللغة", selection: $preferredLanguage) {
                        Text("العربية").tag("ar")
                        Text("English").tag("en")
                    }
                } header: {
                    Text("اللغة")
                } footer: {
                    Text("العربية هي اللغة الأساسية. قد يتطلب تغيير اللغة إعادة تشغيل التطبيق.")
                }

                Section("البيانات") {
                    Button {
                        shareURL = DataExportService.exportFile(context: context)
                        showShare = shareURL != nil
                    } label: { Label("تصدير البيانات (JSON)", systemImage: "square.and.arrow.up") }

                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: { Label("حذف كل بيانات المتابعة", systemImage: "trash") }
                }

                if AppConfig.authEnabled {
                    Section("الحساب") {
                        if let email = auth.userEmail {
                            HStack {
                                Text("الحساب")
                                Spacer()
                                Text(email).foregroundStyle(Theme.textSecondary)
                            }
                        }
                        Button(role: .destructive) {
                            auth.signOut()
                        } label: {
                            Label("تسجيل الخروج", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    }
                }

                Section("معلومات") {
                    NavigationLink {
                        MedicalDisclaimerView(onAccept: {}, showAcceptButton: false)
                    } label: {
                        Label("تنبيه طبي", systemImage: "info.circle.fill")
                            .foregroundStyle(Theme.khabith)
                    }
                    HStack {
                        Text("الإصدار")
                        Spacer()
                        Text(appVersion).foregroundStyle(Theme.textSecondary)
                    }
                }
            }
            .navigationTitle("الإعدادات")
            .sheet(isPresented: $showShare) {
                if let shareURL { ShareSheet(items: [shareURL]) }
            }
            .alert("حذف كل البيانات؟", isPresented: $showDeleteConfirm) {
                Button("إلغاء", role: .cancel) {}
                Button("حذف", role: .destructive) {
                    DataExportService.deleteAllTrackingData(context: context)
                }
            } message: {
                Text("سيتم حذف جميع الوجبات والملخصات وأيام الصيام نهائياً. لا يمكن التراجع.")
            }
        }
    }

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        return v
    }
}

/// غلاف لورقة المشاركة UIActivityViewController.
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
