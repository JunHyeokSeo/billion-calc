import SwiftUI
import BillionCalcCore

struct DepositAdjustmentView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: AppViewModel

    let yearMonth: String

    @State private var amount: Decimal = 0
    @State private var dragStartAmount: Decimal = 0
    @State private var showKeypad: Bool = false
    @FocusState private var keypadFocused: Bool

    private var planned: Decimal {
        viewModel.goal.monthlyDeposit
    }

    private var delta: Decimal {
        amount - planned
    }

    private var originalMonths: Int {
        viewModel.monthsRemaining
    }

    private var projectedMonthsWithDelta: Int? {
        let result = SavingsCalculator.monthsUntilGoal(
            target: viewModel.goal.targetAmount,
            current: max(0, viewModel.goal.currentAmount + amount),
            monthlyDeposit: viewModel.goal.monthlyDeposit,
            annualReturnRate: viewModel.goal.annualReturnRate
        )
        if case .success(let m) = result { return m }
        return nil
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.l) {
                    plannedCard
                    amountCard
                    quickButtons
                    previewCard
                    Spacer(minLength: AppTheme.Spacing.l)
                    PrimaryButton(title: "이번 달 입금 확인", action: confirm)
                }
                .padding(AppTheme.Spacing.m)
            }
            .background(AppTheme.background)
            .navigationTitle(navigationTitleString)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") { dismiss() }
                }
            }
            .onAppear {
                let existing = viewModel.deposits.first(where: { $0.yearMonth == yearMonth })
                amount = existing?.actualAmount ?? planned
                dragStartAmount = amount
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var navigationTitleString: String {
        let month = Int(yearMonth.split(separator: "-").last ?? "") ?? 0
        let isExisting = viewModel.deposits.contains(where: { $0.yearMonth == yearMonth })
        return "\(month)월 입금 \(isExisting ? "수정" : "확인")"
    }

    // MARK: - Planned reference

    private var plannedCard: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Text("계획했던 금액")
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)
            Text(AppFormatters.won(planned))
                .font(.system(.body, design: .rounded))
                .foregroundStyle(AppTheme.subtleText)
        }
        .padding(.top, AppTheme.Spacing.m)
    }

    // MARK: - Amount display + drag

    private var amountCard: some View {
        VStack(spacing: AppTheme.Spacing.s) {
            if delta != 0 {
                HStack(spacing: 4) {
                    Image(systemName: delta > 0 ? "arrow.up" : "arrow.down")
                    Text("계획 대비 \(AppFormatters.won(abs(delta)))")
                }
                .font(.system(.footnote, design: .rounded, weight: .semibold))
                .foregroundStyle(delta > 0 ? AppTheme.success : AppTheme.warning)
                .transition(.opacity)
            } else {
                Text("계획대로")
                    .font(.system(.footnote, design: .rounded, weight: .semibold))
                    .foregroundStyle(AppTheme.secondaryText)
            }

            if showKeypad {
                HStack {
                    TextField("", value: $amount, format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundStyle(amountColor)
                        .focused($keypadFocused)
                    Text("원")
                        .font(.system(.title2, design: .rounded))
                        .foregroundStyle(AppTheme.secondaryText)
                }
                .padding(.vertical, AppTheme.Spacing.l)
                .onChange(of: amount) { _, newValue in
                    if newValue < 0 { amount = 0 }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("완료") {
                            keypadFocused = false
                            showKeypad = false
                            dragStartAmount = amount
                        }
                    }
                }
            } else {
                Text(AppFormatters.won(amount))
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(amountColor)
                    .contentTransition(.numericText())
                    .animation(.spring(duration: 0.2), value: amount)
                    .padding(.vertical, AppTheme.Spacing.l)
                    .gesture(
                        DragGesture(minimumDistance: 1)
                            .onChanged { gesture in
                                let delta = -gesture.translation.height
                                let sensitivity: Double = 200.0
                                let step: Double = 10_000
                                let start = (dragStartAmount as NSDecimalNumber).doubleValue
                                let raw = start + delta * sensitivity
                                let snapped = (raw / step).rounded() * step
                                let next = max(0, snapped)
                                amount = Decimal(next)
                            }
                            .onEnded { _ in
                                dragStartAmount = amount
                            }
                    )
                    .onLongPressGesture(minimumDuration: 0.35) {
                        showKeypad = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            keypadFocused = true
                        }
                    }
            }

            Text(showKeypad ? "금액을 입력 후 완료" : "↑↓ 드래그로 조정 · 길게 눌러 직접 입력")
                .font(.caption)
                .foregroundStyle(AppTheme.subtleText)
        }
        .sensoryFeedback(.selection, trigger: Int((amount as NSDecimalNumber).doubleValue / 100_000))
    }

    private var amountColor: Color {
        if delta > 0 { return AppTheme.success }
        if delta < 0 { return AppTheme.warning }
        return AppTheme.primaryText
    }

    // MARK: - Quick buttons

    private var quickButtons: some View {
        VStack(spacing: AppTheme.Spacing.s) {
            Button {
                withAnimation(.spring(duration: 0.2)) {
                    amount = 0
                    dragStartAmount = 0
                }
            } label: {
                HStack {
                    Image(systemName: "pause.fill")
                    Text("이번 달 쉬어가기 (0원)")
                }
                .font(.system(.callout, design: .rounded, weight: .medium))
                .foregroundStyle(amount == 0 ? .white : AppTheme.primaryText)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.button)
                        .fill(amount == 0 ? AppTheme.warning : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.button)
                                .stroke(AppTheme.primaryText.opacity(0.15), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)

            Button {
                withAnimation(.spring(duration: 0.2)) {
                    amount = planned
                    dragStartAmount = planned
                }
            } label: {
                HStack {
                    Image(systemName: "checkmark")
                    Text("계획대로 \(AppFormatters.won(planned))")
                }
                .font(.system(.callout, design: .rounded, weight: .medium))
                .foregroundStyle(amount == planned ? .white : AppTheme.primaryText)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.button)
                        .fill(amount == planned ? AppTheme.accent : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.button)
                                .stroke(AppTheme.primaryText.opacity(0.15), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Preview

    private var previewCard: some View {
        SectionCard {
            Text("이번 달 입금하면")
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)

            if let newMonths = projectedMonthsWithDelta {
                let diff = originalMonths - newMonths
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("달성 예상")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(AppTheme.secondaryText)
                        Spacer()
                        Text(AppFormatters.monthsDisplay(newMonths))
                            .font(.system(.title3, design: .rounded, weight: .semibold))
                            .foregroundStyle(AppTheme.primaryText)
                    }
                    if diff > 0 {
                        Label("\(diff)개월 앞당겨짐", systemImage: "arrow.up.forward")
                            .font(.system(.footnote, design: .rounded, weight: .semibold))
                            .foregroundStyle(AppTheme.success)
                    } else if diff < 0 {
                        Label("\(abs(diff))개월 지연", systemImage: "arrow.down.forward")
                            .font(.system(.footnote, design: .rounded, weight: .semibold))
                            .foregroundStyle(AppTheme.warning)
                    } else {
                        Text("변화 없음 (계획대로)")
                            .font(.system(.footnote, design: .rounded))
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                }
            } else {
                Text("목표 달성 불가")
                    .font(.system(.callout, design: .rounded, weight: .semibold))
                    .foregroundStyle(AppTheme.danger)
            }
        }
    }

    // MARK: - Confirm

    private func confirm() {
        viewModel.confirmDeposit(forYearMonth: yearMonth, actualAmount: amount)
        dismiss()
    }
}
