import SwiftUI
import BillionCalcCore

// MARK: - User-selectable color scheme

enum AppColorScheme: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: return "시스템"
        case .light:  return "라이트"
        case .dark:   return "다크"
        }
    }

    /// `nil` = follow system, otherwise force the given scheme.
    var swiftUI: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

// MARK: - Theme tokens

enum AppTheme {
    static let accent = Color(red: 0.95, green: 0.72, blue: 0.18)        // 금색
    static let accentDark = Color(red: 1.0, green: 0.82, blue: 0.28)

    static func dynamicAccent(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? accentDark : accent
    }

    static let cardBackground = Color(.secondarySystemBackground)
    static let primaryText = Color(.label)
    static let secondaryText = Color(.secondaryLabel)
    static let subtleText = Color(.tertiaryLabel)
    static let background = Color(.systemBackground)

    static let success = Color(red: 0.18, green: 0.70, blue: 0.42)
    static let warning = Color(red: 0.95, green: 0.45, blue: 0.18)
    static let danger = Color(red: 0.90, green: 0.25, blue: 0.25)

    enum Radius {
        static let card: CGFloat = 20
        static let button: CGFloat = 14
        static let chip: CGFloat = 10
    }
    enum Spacing {
        static let xs: CGFloat = 4
        static let s: CGFloat = 8
        static let m: CGFloat = 16
        static let l: CGFloat = 24
        static let xl: CGFloat = 32
    }
}

// MARK: - Formatters

enum AppFormatters {
    static let decimal: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = ","
        f.maximumFractionDigits = 0
        return f
    }()

    static let shortDecimal: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = ","
        f.maximumFractionDigits = 0
        return f
    }()

    static let date: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy년 M월 d일"
        return f
    }()

    static let yearMonth: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy년 M월"
        return f
    }()

    static func won(_ value: Decimal) -> String {
        "\(decimal.string(from: value as NSDecimalNumber) ?? "0")원"
    }

    static func compactWon(_ value: Decimal) -> String {
        let d = (value as NSDecimalNumber).doubleValue
        if d >= 100_000_000 {
            let eok = d / 100_000_000
            if eok >= 10 {
                return String(format: "%.0f억", eok)
            }
            return String(format: "%.1f억", eok).replacingOccurrences(of: ".0억", with: "억")
        }
        if d >= 10_000 {
            let man = d / 10_000
            if man >= 1000 {
                return String(format: "%.0f만", man)
            }
            return String(format: "%.0f만", man)
        }
        return "\(Int(d))원"
    }

    static func monthsDisplay(_ months: Int) -> String {
        if months == 0 { return "오늘" }
        if months < 12 { return "\(months)개월" }
        let y = months / 12
        let m = months % 12
        if m == 0 { return "\(y)년" }
        return "\(y)년 \(m)개월"
    }
}

// MARK: - Shared components

struct SectionCard<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.m) {
            content()
        }
        .padding(AppTheme.Spacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))
    }
}

struct ProgressRingView: View {
    let progress: Double
    let lineWidth: CGFloat
    let tint: Color

    init(progress: Double, lineWidth: CGFloat = 12, tint: Color = AppTheme.accent) {
        self.progress = max(0, min(1, progress))
        self.lineWidth = lineWidth
        self.tint = tint
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppTheme.cardBackground, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.4), value: progress)
        }
    }
}

struct LinearProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppTheme.primaryText.opacity(0.1))
                ForEach([0.25, 0.5, 0.75], id: \.self) { p in
                    Circle()
                        .fill(AppTheme.primaryText.opacity(0.28))
                        .frame(width: 3, height: 3)
                        .offset(x: CGFloat(p) * geo.size.width - 1.5, y: 0)
                }
                Capsule()
                    .fill(AppTheme.accent)
                    .frame(width: max(0, min(1, progress)) * geo.size.width)
                    .animation(.easeInOut(duration: 0.4), value: progress)
            }
        }
        .frame(height: 10)
    }
}

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            action()
        } label: {
            Text(title)
                .font(.system(.body, design: .rounded, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.button)
                        .fill(isEnabled ? AppTheme.accent : Color.gray.opacity(0.4))
                )
        }
        .disabled(!isEnabled)
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.callout, design: .rounded, weight: .medium))
                .foregroundStyle(AppTheme.primaryText)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.button)
                        .stroke(AppTheme.primaryText.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

struct CurrencyField: View {
    let title: String
    @Binding var value: Decimal
    var placeholder: String = "0"

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text(title)
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)
            HStack {
                TextField(placeholder, value: $value, format: .number)
                    .keyboardType(.numberPad)
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryText)
                Text("원")
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.button))
        }
    }
}

struct IntField: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    var suffix: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text(title)
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)
            HStack {
                TextField("", value: $value, format: .number)
                    .keyboardType(.numberPad)
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryText)
                if !suffix.isEmpty {
                    Text(suffix)
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.button))
            .onChange(of: value) { _, newValue in
                if newValue < range.lowerBound { value = range.lowerBound }
                if newValue > range.upperBound { value = range.upperBound }
            }
        }
    }
}

// MARK: - Editable number display (tap-to-edit affordance)

private struct EditableNumberButton: View {
    let label: String
    let size: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text(label)
                    .font(.system(size: size, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)
                    .contentTransition(.numericText())
                Image(systemName: "square.and.pencil")
                    .font(.system(size: max(12, size * 0.32)))
                    .foregroundStyle(AppTheme.subtleText)
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct TargetAmountSlider: View {
    @Binding var value: Decimal
    @State private var showEditor = false
    @Environment(\.colorScheme) private var currentScheme

    static let minValue: Double = 0
    static let maxValue: Double = 300_000_000     // 3억
    static let step: Double = 10_000_000           // 1천만 단위 (슬라이더가 실질적 칩 갤러리 역할)

    private var doubleBinding: Binding<Double> {
        Binding(
            get: { (value as NSDecimalNumber).doubleValue },
            set: { value = Decimal($0) }
        )
    }

    private var tickKey: Int { Int(((value as NSDecimalNumber).doubleValue / Self.step).rounded()) }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.s) {
            Text("목표 금액")
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)
            EditableNumberButton(
                label: AppFormatters.compactWon(value),
                size: 40
            ) { showEditor = true }
            Slider(value: doubleBinding, in: Self.minValue...Self.maxValue, step: Self.step)
                .tint(AppTheme.accent)
            HStack {
                Text(AppFormatters.compactWon(Decimal(Self.minValue)))
                    .font(.caption2)
                    .foregroundStyle(AppTheme.subtleText)
                Spacer()
                Text(AppFormatters.compactWon(Decimal(Self.maxValue)))
                    .font(.caption2)
                    .foregroundStyle(AppTheme.subtleText)
            }
        }
        .sensoryFeedback(.selection, trigger: tickKey)
        .sheet(isPresented: $showEditor) {
            AmountEditorSheet(
                title: "목표 금액",
                value: $value,
                minValue: Self.minValue,
                maxValue: Self.maxValue,
                step: Self.step
            )
            .preferredColorScheme(currentScheme)
        }
    }
}

struct AmountSlider: View {
    let title: String
    @Binding var value: Decimal
    let minValue: Double
    let maxValue: Double
    let step: Double
    @State private var showEditor = false
    @Environment(\.colorScheme) private var currentScheme

    private var doubleBinding: Binding<Double> {
        Binding(
            get: { (value as NSDecimalNumber).doubleValue },
            set: { value = Decimal($0) }
        )
    }

    private var tickKey: Int { Int(((value as NSDecimalNumber).doubleValue / step).rounded()) }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.s) {
            Text(title)
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)
            EditableNumberButton(
                label: AppFormatters.compactWon(value),
                size: 28
            ) { showEditor = true }
            Slider(value: doubleBinding, in: minValue...maxValue, step: step)
                .tint(AppTheme.accent)
            HStack {
                Text(AppFormatters.compactWon(Decimal(minValue)))
                    .font(.caption2)
                    .foregroundStyle(AppTheme.subtleText)
                Spacer()
                Text(AppFormatters.compactWon(Decimal(maxValue)))
                    .font(.caption2)
                    .foregroundStyle(AppTheme.subtleText)
            }
        }
        .sensoryFeedback(.selection, trigger: tickKey)
        .sheet(isPresented: $showEditor) {
            AmountEditorSheet(
                title: title,
                value: $value,
                minValue: minValue,
                maxValue: maxValue,
                step: step
            )
            .preferredColorScheme(currentScheme)
        }
    }
}

struct PercentSlider: View {
    let title: String
    @Binding var value: Double
    var range: ClosedRange<Double> = 0...15
    var step: Double = 0.1
    @State private var showEditor = false
    @Environment(\.colorScheme) private var currentScheme

    private var tickKey: Int { Int((value / step).rounded()) }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.s) {
            Text(title)
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)
            EditableNumberButton(
                label: String(format: "%.1f%%", value),
                size: 28
            ) { showEditor = true }
            Slider(value: $value, in: range, step: step)
                .tint(AppTheme.accent)
            HStack {
                Text(String(format: "%.0f%%", range.lowerBound))
                    .font(.caption2)
                    .foregroundStyle(AppTheme.subtleText)
                Spacer()
                Text(String(format: "%.0f%%", range.upperBound))
                    .font(.caption2)
                    .foregroundStyle(AppTheme.subtleText)
            }
        }
        .sensoryFeedback(.selection, trigger: tickKey)
        .sheet(isPresented: $showEditor) {
            PercentEditorSheet(
                title: title,
                value: $value,
                range: range,
                step: step
            )
            .preferredColorScheme(currentScheme)
        }
    }
}

// MARK: - Editor sheets

struct AmountEditorSheet: View {
    let title: String
    @Binding var value: Decimal
    let minValue: Double
    let maxValue: Double
    let step: Double

    @Environment(\.dismiss) private var dismiss
    @State private var text: String = ""
    @FocusState private var focused: Bool

    private var parsedValue: Double? {
        let digits = text.filter(\.isNumber)
        guard !digits.isEmpty, let n = Double(digits) else { return nil }
        return n
    }

    private var previewText: String {
        guard let n = parsedValue, n > 0 else { return " " }
        return "\(AppFormatters.compactWon(Decimal(n))) · \(AppFormatters.won(Decimal(n)))"
    }

    private var outOfRange: Bool {
        guard let n = parsedValue else { return false }
        return n > maxValue
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.l) {
            HStack {
                Button("취소") { dismiss() }
                Spacer()
                Text(title)
                    .font(.system(.headline, design: .rounded))
                Spacer()
                Button("완료") { commit() }
                    .fontWeight(.semibold)
            }
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                TextField("0", text: $text)
                    .keyboardType(.numberPad)
                    .focused($focused)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.trailing)
                Text("원")
                    .font(.system(.title3, design: .rounded))
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .padding(AppTheme.Spacing.m)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.button))
            Text(outOfRange ? "최대 \(AppFormatters.compactWon(Decimal(maxValue))) 까지 입력 가능" : previewText)
                .font(.caption)
                .foregroundStyle(outOfRange ? AppTheme.danger : AppTheme.secondaryText)
                .frame(maxWidth: .infinity, alignment: .center)
            Spacer(minLength: 0)
        }
        .padding(AppTheme.Spacing.l)
        .presentationDetents([.height(260)])
        .presentationDragIndicator(.visible)
        .onAppear {
            let d = (value as NSDecimalNumber).doubleValue
            text = d > 0 ? String(Int(d)) : ""
        }
        .task {
            try? await Task.sleep(for: .milliseconds(80))
            focused = true
        }
    }

    private func commit() {
        if let n = parsedValue {
            let clamped = min(maxValue, max(minValue, n))
            let snapped = (clamped / step).rounded() * step
            value = Decimal(snapped)
        }
        dismiss()
    }
}

struct PercentEditorSheet: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double

    @Environment(\.dismiss) private var dismiss
    @State private var text: String = ""
    @FocusState private var focused: Bool

    private var parsedValue: Double? { Double(text.replacingOccurrences(of: ",", with: ".")) }

    private var outOfRange: Bool {
        guard let n = parsedValue else { return false }
        return n > range.upperBound
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.l) {
            HStack {
                Button("취소") { dismiss() }
                Spacer()
                Text(title)
                    .font(.system(.headline, design: .rounded))
                Spacer()
                Button("완료") { commit() }
                    .fontWeight(.semibold)
            }
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                TextField("0.0", text: $text)
                    .keyboardType(.decimalPad)
                    .focused($focused)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.trailing)
                Text("%")
                    .font(.system(.title3, design: .rounded))
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .padding(AppTheme.Spacing.m)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.button))
            Text(outOfRange
                 ? String(format: "최대 %.0f%% 까지 입력 가능", range.upperBound)
                 : "연 복리 기준")
                .font(.caption)
                .foregroundStyle(outOfRange ? AppTheme.danger : AppTheme.secondaryText)
                .frame(maxWidth: .infinity, alignment: .center)
            Spacer(minLength: 0)
        }
        .padding(AppTheme.Spacing.l)
        .presentationDetents([.height(260)])
        .presentationDragIndicator(.visible)
        .onAppear {
            text = value > 0 ? String(format: "%.1f", value) : ""
        }
        .task {
            try? await Task.sleep(for: .milliseconds(80))
            focused = true
        }
    }

    private func commit() {
        if let n = parsedValue {
            let clamped = min(range.upperBound, max(range.lowerBound, n))
            let snapped = (clamped / step).rounded() * step
            value = snapped
        }
        dismiss()
    }
}

struct PaydayGridPicker: View {
    @Binding var selectedDay: Int

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.s) {
            Text("월급일")
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(1...31, id: \.self) { day in
                    Button {
                        selectedDay = day
                    } label: {
                        Text("\(day)")
                            .font(.system(.callout, design: .rounded, weight: .semibold))
                            .foregroundStyle(selectedDay == day ? .white : AppTheme.primaryText)
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedDay == day ? AppTheme.accent : AppTheme.cardBackground)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            Text("매달 \(selectedDay)일")
                .font(.caption2)
                .foregroundStyle(AppTheme.subtleText)
        }
        .sensoryFeedback(.selection, trigger: selectedDay)
    }
}

struct PercentField: View {
    let title: String
    @Binding var value: Double

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text(title)
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)
            HStack {
                TextField("", value: $value, format: .number.precision(.fractionLength(0...2)))
                    .keyboardType(.decimalPad)
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryText)
                Text("%")
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.button))
            .onChange(of: value) { _, newValue in
                if newValue < 0 { value = 0 }
                if newValue > 100 { value = 100 }
            }
        }
    }
}

// strippingEmoji() moved to BillionCalcCore (Sources/BillionCalcCore/String+Emoji.swift)
// so the Widget target can use the same implementation.
