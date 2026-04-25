import WidgetKit
import SwiftUI
import BillionCalcCore

// MARK: - Shared colors
// Mirrors AppTheme.accent / AppTheme.success — widget target can't import App/AppTheme.swift.
private let widgetAccent = Color(red: 0.95, green: 0.72, blue: 0.18)
private let widgetSuccess = Color(red: 0.18, green: 0.70, blue: 0.42)

// MARK: - Entry

struct BillionCalcEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot?
}

// MARK: - Provider

struct BillionCalcProvider: TimelineProvider {
    func placeholder(in context: Context) -> BillionCalcEntry {
        BillionCalcEntry(
            date: Date(),
            snapshot: WidgetSnapshot(
                progress: 0.35,
                daysRemaining: 1247,
                monthsRemaining: 41,
                currentAmount: 35_000_000,
                targetAmount: 100_000_000,
                motivationText: "오늘도 목표에 가까워졌어요",
                generatedAt: Date(),
                isImpossible: false
            )
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (BillionCalcEntry) -> Void) {
        let storage = SharedStorage(defaults: SharedStorage.defaultAppGroup)
        let snap = WidgetSnapshot.build(from: storage)
        completion(BillionCalcEntry(date: Date(), snapshot: snap))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BillionCalcEntry>) -> Void) {
        let storage = SharedStorage(defaults: SharedStorage.defaultAppGroup)
        let now = Date()
        let snap = WidgetSnapshot.build(from: storage, now: now)
        let entry = BillionCalcEntry(date: now, snapshot: snap)

        // Periodic refresh runs once per day at midnight — catches payday/anniversary
        // category changes. State-driven updates (goal save, deposit confirm) come
        // from the app via WidgetCenter.reloadAllTimelines().
        let calendar = Calendar.current
        let nextMidnight = calendar.startOfDay(for: now.addingTimeInterval(86_400))
        let timeline = Timeline(entries: [entry], policy: .after(nextMidnight))
        completion(timeline)
    }
}

// MARK: - Widget

struct BillionCalcWidget: Widget {
    let kind: String = "BillionCalcWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BillionCalcProvider()) { entry in
            BillionCalcWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(.systemBackground)
                }
        }
        .configurationDisplayName("1억 계산기")
        .description("목표 금액까지 남은 D-Day와 진행률을 확인하세요")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Shared view

struct BillionCalcWidgetView: View {
    let entry: BillionCalcEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .systemMedium:
            MediumView(entry: entry)
        default:
            SmallView(entry: entry)
        }
    }
}

private struct SmallView: View {
    let entry: BillionCalcEntry

    var body: some View {
        if let snap = entry.snapshot {
            ZStack {
                ProgressRing(progress: snap.progress)
                VStack(spacing: 0) {
                    if snap.isImpossible {
                        Text("설정\n필요")
                            .font(.system(.subheadline, weight: .bold))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.orange)
                    } else if snap.progress >= 1.0 {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundStyle(widgetSuccess)
                        Text("달성")
                            .font(.system(.headline, weight: .bold))
                            .foregroundStyle(.primary)
                            .padding(.top, 2)
                    } else {
                        Text("\(snap.monthsRemaining)")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundStyle(.primary)
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                            .contentTransition(.numericText())
                        Text("개월 남음")
                            .font(.system(.caption2, weight: .medium))
                            .foregroundStyle(.secondary)
                            .tracking(1.2)
                    }
                }
            }
        } else {
            PlaceholderView()
        }
    }
}

private struct MediumView: View {
    let entry: BillionCalcEntry

    var body: some View {
        if let snap = entry.snapshot {
            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    ProgressRing(progress: snap.progress, lineWidth: 12)
                    ringContent(for: snap)
                }
                .frame(width: 124, height: 124)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(widgetAccent)
                            .frame(width: 6, height: 6)
                        Text("\(Int((snap.progress * 100).rounded()))% 도달")
                            .font(.system(.footnote, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .contentTransition(.numericText())
                    }

                    Text(motivationLine(snap))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)

                    Spacer(minLength: 0)

                    if let mile = nextMilestoneLine(snap) {
                        Text(mile)
                            .font(.system(.caption2, weight: .medium))
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        } else {
            PlaceholderView()
        }
    }

    @ViewBuilder
    private func ringContent(for snap: WidgetSnapshot) -> some View {
        if snap.isImpossible {
            Text("설정\n필요")
                .font(.system(.subheadline, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.orange)
        } else if snap.progress >= 1.0 {
            VStack(spacing: 2) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundStyle(widgetSuccess)
                Text("달성")
                    .font(.system(.subheadline, weight: .bold))
                    .foregroundStyle(.primary)
            }
        } else {
            VStack(spacing: 0) {
                Text("\(snap.monthsRemaining)")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Text("개월 남음")
                    .font(.system(.caption2, weight: .medium))
                    .foregroundStyle(.secondary)
                    .tracking(0.6)
                    .padding(.top, 1)
            }
            .padding(.horizontal, 14)
        }
    }

    private func motivationLine(_ snap: WidgetSnapshot) -> String {
        let cleaned = snap.motivationText.strippingEmoji()
        if cleaned.isEmpty {
            return snap.progress >= 1.0 ? "목표를 이뤘어요\n정말 수고했어요" : "오늘도 한 걸음\n가까워지고 있어요"
        }
        return cleaned
    }

    private func nextMilestoneLine(_ snap: WidgetSnapshot) -> String? {
        let p = snap.progress
        if p >= 1.0 { return nil }
        let thresholds: [Double] = [0.25, 0.5, 0.75, 1.0]
        guard let nextT = thresholds.first(where: { $0 > p }) else { return nil }
        let amount = snap.targetAmount * Decimal(nextT)
        let pct = Int((nextT * 100).rounded())
        return "다음 \(pct)% · \(compactWonShort(amount))"
    }

    private func compactWonShort(_ d: Decimal) -> String {
        let v = (d as NSDecimalNumber).doubleValue
        if v >= 100_000_000 {
            let eok = v / 100_000_000
            return eok == eok.rounded() ? "\(Int(eok))억" : String(format: "%.1f억", eok)
        }
        if v >= 10_000 {
            let man = v / 10_000
            return "\(Int(man))만"
        }
        return "\(Int(v))원"
    }
}

private struct PlaceholderView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "target")
                .font(.system(size: 28))
                .foregroundStyle(.secondary)
            Text("앱에서 목표 설정")
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

private struct ProgressRing: View {
    let progress: Double
    var lineWidth: CGFloat = 8

    var body: some View {
        let p = max(0, min(1, progress))
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.2), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: p)
                .stroke(
                    widgetAccent,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
    }
}
