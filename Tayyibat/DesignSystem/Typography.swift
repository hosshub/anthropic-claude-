import SwiftUI

/// أنماط الخطوط. على اللغة العربية يستخدم النظام تلقائياً خط SF Arabic.
extension Font {
    static let displayTitle = Font.system(size: 32, weight: .bold, design: .rounded)
    static let screenTitle = Font.system(size: 24, weight: .bold)
    static let sectionTitle = Font.system(size: 19, weight: .semibold)
    static let cardTitle = Font.system(size: 17, weight: .semibold)
    static let bodyText = Font.system(size: 16, weight: .regular)
    static let caption = Font.system(size: 13, weight: .regular)
    static let scoreNumber = Font.system(size: 56, weight: .heavy, design: .rounded)
}

extension View {
    /// تباعد أسطر مريح للقراءة بالعربية.
    func arabicBody() -> some View {
        self.font(.bodyText)
            .lineSpacing(6)
            .foregroundStyle(Theme.textPrimary)
    }
}
