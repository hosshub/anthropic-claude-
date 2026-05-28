import SwiftUI

/// نبذة محايدة عن فلسفة النظام (بدون ادعاءات صحية).
struct PhilosophyView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("عن نظام الطيبات")
                        .font(.screenTitle)
                        .foregroundStyle(Theme.textPrimary)

                    Text("نظام الطيبات تصنيف للأطعمة إلى \"طيّبات\" مسموحة و\"خبائث\" متجنَّبة، مع جملة من القواعد السلوكية حول توقيت الأكل والصيام.")
                        .arabicBody()

                    feature("fork.knife", "تصنيف الأطعمة", "كل طعام يُصنَّف طيّباً أو خبيثاً أو مشروطاً وفق قوائم النظام.")
                    feature("clock", "الإصغاء للجوع", "الأكل عند الجوع الحقيقي والتوقف قبل الشبع الكامل، دون مواعيد ثابتة.")
                    feature("moon.stars", "الصيام", "صيام الإثنين والخميس والأيام البيض إضافةً للصيام المتقطع.")
                    feature("camera", "المتابعة بالصورة", "تصوّر وجبتك فيحلّلها التطبيق ويعرض مدى توافقها مع النظام.")

                    Text("هذا التطبيق لا يتبنّى موقفاً طبياً من النظام؛ هو أداة محايدة لمن اختار اتباعه.")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                        .padding(.top, 4)
                }
                .padding(20)
            }
            PrimaryButton(title: "متابعة", systemImage: "arrow.left", action: onContinue)
                .padding(20)
        }
        .background(Theme.background)
    }

    private func feature(_ icon: String, _ title: String, _ body: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Theme.primary)
                .frame(width: 34)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.cardTitle).foregroundStyle(Theme.textPrimary)
                Text(body).font(.bodyText).foregroundStyle(Theme.textSecondary).lineSpacing(4)
            }
        }
    }
}
