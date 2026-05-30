import SwiftUI

/// ٠٧ — بنوك الوجبات. الواجهة الفعلية في `MealBanksView`؛ هذا غلاف رفيع
/// كي يبقى مرجع `GuideSection.mealBanks` ثابتاً.
struct GuideMealBanksView: View {
    var body: some View {
        MealBanksView()
    }
}
