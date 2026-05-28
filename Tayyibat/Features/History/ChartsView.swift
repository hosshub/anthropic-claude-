import SwiftUI
import Charts

struct DayScore: Identifiable {
    let id = UUID()
    let date: Date
    let score: Int
}

/// رسم بياني لمتوسط الالتزام عبر فترة.
struct AdherenceChart: View {
    let title: String
    let data: [DayScore]
    var useBars: Bool = true

    private var average: Int {
        let scored = data.filter { $0.score > 0 }
        guard !scored.isEmpty else { return 0 }
        return scored.map(\.score).reduce(0, +) / scored.count
    }

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(title).font(.cardTitle).foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Text("المتوسط \(average)%")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.primary)
                }

                Chart(data) { point in
                    if useBars {
                        BarMark(
                            x: .value("اليوم", point.date, unit: .day),
                            y: .value("النسبة", point.score)
                        )
                        .foregroundStyle(Theme.scoreColor(point.score))
                        .cornerRadius(4)
                    } else {
                        LineMark(
                            x: .value("اليوم", point.date, unit: .day),
                            y: .value("النسبة", point.score)
                        )
                        .foregroundStyle(Theme.primary)
                        .interpolationMethod(.catmullRom)
                        AreaMark(
                            x: .value("اليوم", point.date, unit: .day),
                            y: .value("النسبة", point.score)
                        )
                        .foregroundStyle(Theme.primary.opacity(0.12))
                        .interpolationMethod(.catmullRom)
                    }
                }
                .chartYScale(domain: 0...100)
                .frame(height: 160)
            }
        }
    }
}
