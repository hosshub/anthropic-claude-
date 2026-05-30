import SwiftUI

/// بطاقة موجزة لمتابعة الجسم — تُعرض في تفاصيل الوجبة.
struct BodyResponseSummaryCard: View {
    let response: BodyResponse
    var onEdit: () -> Void = {}

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("متابعة الجسم", systemImage: "heart.text.square.fill")
                        .font(.cardTitle.weight(.semibold))
                        .foregroundStyle(Theme.primary)
                    Spacer()
                    Button("تعديل", action: onEdit)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.primary)
                }

                HStack(spacing: 12) {
                    metric(icon: "fork.knife.circle.fill",
                           label: "الشبع",
                           value: satisfactionText)
                    metric(icon: "wind",
                           label: "الانتفاخ",
                           value: bloatingText,
                           color: bloatingColor)
                    metric(icon: "bolt.fill",
                           label: "الطاقة",
                           value: energyText)
                }

                HStack(spacing: 12) {
                    pillRow(icon: "moon.stars.fill", text: response.sleepImpact.labelAr)
                    pillRow(icon: response.worthRepeating == .yes ? "hand.thumbsup.fill"
                                     : (response.worthRepeating == .no ? "hand.thumbsdown.fill" : "questionmark"),
                            text: response.worthRepeating.labelAr,
                            color: worthColor)
                }

                if let notes = response.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.bodyText)
                        .foregroundStyle(Theme.textSecondary)
                        .padding(.top, 4)
                }

                Text("سُجّلت بعد \(response.hoursAfterMeal) ساعة من الوجبة")
                    .font(.caption2)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
    }

    private func metric(icon: String, label: String, value: String, color: Color = Theme.primary) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: icon).foregroundStyle(color)
                Text(label).font(.caption).foregroundStyle(Theme.textSecondary)
            }
            Text(value)
                .font(.cardTitle.weight(.semibold))
                .foregroundStyle(Theme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func pillRow(icon: String, text: String, color: Color = Theme.primary) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon).foregroundStyle(color)
            Text(text).font(.caption).foregroundStyle(Theme.textPrimary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.10), in: Capsule())
    }

    private var satisfactionText: String {
        switch response.satisfyingFullness {
        case 1: return "لا شبع"
        case 2: return "خفيف"
        case 3: return "مريح"
        case 4: return "كامل"
        default: return "ممتلئ جداً"
        }
    }

    private var bloatingText: String {
        switch response.bloating {
        case 0: return "مرتاح"
        case 1, 2: return "خفيف"
        case 3: return "ملحوظ"
        case 4: return "واضح"
        default: return "شديد"
        }
    }

    private var bloatingColor: Color {
        switch response.bloating {
        case 0: return Theme.primary
        case 1, 2: return Theme.gold
        default: return Theme.khabith
        }
    }

    private var energyText: String {
        switch response.energyLevel {
        case 1: return "نعسان"
        case 2: return "خامل"
        case 3: return "عادي"
        case 4: return "نشيط"
        default: return "نشيط جداً"
        }
    }

    private var worthColor: Color {
        switch response.worthRepeating {
        case .yes: return Theme.primary
        case .maybe: return Theme.gold
        case .no: return Theme.khabith
        }
    }
}
