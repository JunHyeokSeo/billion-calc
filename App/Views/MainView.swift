import SwiftUI
import BillionCalcCore

struct MainView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @State private var showSettings = false
    @State private var showDepositAdjustment = false
    @State private var motivationText: String = ""
    @State private var whatIfOverride: Double = 0
    @State private var showWhatIf: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.l) {
                    headerCard
                    progressCard
                    if !viewModel.currentMonthConfirmed {
                        depositBanner
                    }
                    motivationCard
                    whatIfCard
                    journeyCard
                }
                .padding(AppTheme.Spacing.m)
            }
            .background(AppTheme.background)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(viewModel)
                    .preferredColorScheme(viewModel.colorScheme.swiftUI)
            }
            .sheet(isPresented: $showDepositAdjustment) {
                DepositAdjustmentView(yearMonth: viewModel.currentYearMonth)
                    .environmentObject(viewModel)
                    .preferredColorScheme(viewModel.colorScheme.swiftUI)
            }
            .onAppear { loadMotivation() }
            .onChange(of: viewModel.goal) { _, _ in loadMotivation() }
        }
    }

    // MARK: - Cards

    private var headerCard: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: AppTheme.Spacing.s) {
                Text("목표 \(AppFormatters.compactWon(viewModel.goal.targetAmount))까지")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(AppTheme.secondaryText)

                if viewModel.isImpossible {
                    Text("달성 불가")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(AppTheme.danger)
                    Text("월 저축이 있어야 도달할 수 있어요")
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(AppTheme.secondaryText)
                } else if viewModel.isAchieved {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 48, weight: .bold))
                        Text("달성")
                            .font(.system(size: 56, weight: .bold))
                    }
                    .foregroundStyle(AppTheme.success)
                    Text("목표를 이뤘어요")
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(AppTheme.secondaryText)
                } else {
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("\(viewModel.monthsRemaining)")
                            .font(.system(size: 72, weight: .bold))
                            .foregroundStyle(AppTheme.primaryText)
                            .contentTransition(.numericText())
                        Text("개월 남음")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(AppTheme.secondaryText)
                            .padding(.bottom, 6)
                    }
                    Text("\(AppFormatters.date.string(from: viewModel.projectedDate)) 달성 예상")
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(AppTheme.subtleText)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.l)

            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(AppTheme.secondaryText)
                    .padding(AppTheme.Spacing.s)
            }
            .accessibilityLabel("설정")
        }
    }

    private var progressCard: some View {
        SectionCard {
            HStack(alignment: .firstTextBaseline) {
                Text("저축 현황")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(AppTheme.secondaryText)
                Spacer()
                Text("\(Int((viewModel.progress * 100).rounded()))%")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(AppTheme.accent)
                    .contentTransition(.numericText())
            }
            LinearProgressBar(progress: viewModel.progress)
            HStack {
                Text("\(AppFormatters.compactWon(viewModel.goal.currentAmount)) 모음")
                    .font(.system(.footnote, design: .rounded, weight: .medium))
                    .foregroundStyle(AppTheme.secondaryText)
                Spacer()
                Text("목표 \(AppFormatters.compactWon(viewModel.goal.targetAmount))")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(AppTheme.subtleText)
            }
        }
    }

    private var motivationCard: some View {
        SectionCard {
            HStack(alignment: .top, spacing: AppTheme.Spacing.m) {
                Image(systemName: "quote.opening")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.accent.opacity(0.7))
                    .frame(width: 24)
                Text(motivationText.isEmpty ? " " : motivationText.strippingEmoji())
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .foregroundStyle(AppTheme.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .id(motivationText)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                Button {
                    loadMotivation(forceNew: true)
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.secondaryText)
                }
                .accessibilityLabel("다른 응원 보기")
            }
        }
    }

    private var depositBanner: some View {
        Button {
            showDepositAdjustment = true
        } label: {
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundStyle(AppTheme.accent)
                VStack(alignment: .leading, spacing: 2) {
                    Text("이번 달 입금 확인이 필요해요")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(AppTheme.primaryText)
                    Text("계획대로라면 \(AppFormatters.won(viewModel.goal.monthlyDeposit))")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .padding(AppTheme.Spacing.m)
            .background(AppTheme.accent.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
        }
        .buttonStyle(.plain)
    }

    private var whatIfCard: some View {
        SectionCard {
            HStack {
                Text("만약에")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
                Spacer()
                Toggle("", isOn: $showWhatIf.animation())
                    .labelsHidden()
            }
            if showWhatIf {
                let planned = (viewModel.goal.monthlyDeposit as NSDecimalNumber).doubleValue
                let minV = max(0, planned - 1_000_000)
                let maxV = planned + 2_000_000
                Text("월 저축 \(AppFormatters.won(Decimal(planned + whatIfOverride)))")
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryText)
                Slider(value: $whatIfOverride, in: (minV - planned)...(maxV - planned), step: 50_000)
                    .tint(AppTheme.accent)
                if let newMonths = viewModel.simulateMonths(withMonthlyDeposit: Decimal(planned + whatIfOverride)) {
                    let diff = viewModel.monthsRemaining - newMonths
                    if diff > 0 {
                        Text("\(diff)개월 단축 → \(AppFormatters.monthsDisplay(newMonths)) 만에 달성")
                            .font(.system(.callout, design: .rounded, weight: .medium))
                            .foregroundStyle(AppTheme.success)
                    } else if diff < 0 {
                        Text("\(abs(diff))개월 지연 → \(AppFormatters.monthsDisplay(newMonths)) 걸림")
                            .font(.system(.callout, design: .rounded, weight: .medium))
                            .foregroundStyle(AppTheme.warning)
                    } else {
                        Text("변화 없음")
                            .font(.system(.callout, design: .rounded))
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                }
            } else {
                Text("월 저축을 조정하면 목표일이 어떻게 달라지는지 확인")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
    }

    private var journeyCard: some View {
        SectionCard {
            HStack {
                Text("저축 여정")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
                Spacer()
            }
            journeyRow(label: "시작일", value: journeyStartLabel)
            journeyRow(label: "총 저축액", value: AppFormatters.compactWon(viewModel.goal.currentAmount))
            journeyRow(label: "평균 월 저축", value: averageDepositLabel)
            journeyRow(label: "다음 이정표", value: nextMilestoneLabel, emphasized: true)
        }
    }

    private func journeyRow(label: String, value: String, emphasized: Bool = false) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(AppTheme.secondaryText)
            Spacer()
            Text(value)
                .font(.system(.footnote, design: .rounded, weight: emphasized ? .semibold : .medium))
                .foregroundStyle(emphasized ? AppTheme.accent : AppTheme.primaryText)
                .contentTransition(.numericText())
                .multilineTextAlignment(.trailing)
        }
    }

    private var journeyStartLabel: String {
        let start = viewModel.goal.startDate
        let days = max(0, Int(Date().timeIntervalSince(start) / 86_400))
        let date = AppFormatters.date.string(from: start)
        return days == 0 ? "오늘 · \(date)" : "\(days)일 전 · \(date)"
    }

    private var averageDepositLabel: String {
        let deposits = viewModel.deposits
        guard !deposits.isEmpty else { return "—" }
        let total = deposits.reduce(Decimal(0)) { $0 + $1.actualAmount }
        let avg = total / Decimal(deposits.count)
        return AppFormatters.compactWon(avg)
    }

    private var nextMilestoneLabel: String {
        let progress = viewModel.progress
        if progress >= 1.0 { return "목표 달성!" }
        let thresholds: [Double] = [0.25, 0.5, 0.75, 1.0]
        guard let nextT = thresholds.first(where: { $0 > progress }) else { return "—" }
        let target = viewModel.goal.targetAmount
        let thresholdAmount = target * Decimal(nextT)
        let remaining = thresholdAmount - viewModel.goal.currentAmount
        let thresholdText = "\(Int((nextT * 100).rounded()))% · \(AppFormatters.compactWon(thresholdAmount))"
        let monthlyDeposit = viewModel.goal.monthlyDeposit
        guard remaining > 0, monthlyDeposit > 0 else { return thresholdText }
        let monthsDouble = (remaining as NSDecimalNumber).doubleValue / (monthlyDeposit as NSDecimalNumber).doubleValue
        let months = Int(monthsDouble.rounded(.up))
        return "\(thresholdText) · \(months)개월 뒤"
    }

    // MARK: - Helpers

    private func loadMotivation(forceNew: Bool = false) {
        withAnimation(.spring(duration: 0.3)) {
            motivationText = viewModel.motivation()
        }
    }
}
