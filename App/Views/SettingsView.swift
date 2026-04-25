import SwiftUI
import BillionCalcCore

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: AppViewModel

    @State private var targetAmount: Decimal = 0
    @State private var currentAmount: Decimal = 0
    @State private var monthlyDeposit: Decimal = 0
    @State private var paydayOfMonth: Int = 25
    @State private var annualReturnRate: Double = 0
    @State private var showResetConfirm = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.l) {
                    SectionCard {
                        TargetAmountSlider(value: $targetAmount)
                    }

                    SectionCard {
                        Text("저축 현황")
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryText)
                        AmountSlider(
                            title: "현재 보유 금액",
                            value: $currentAmount,
                            minValue: 0,
                            maxValue: 300_000_000,
                            step: 500_000
                        )
                        AmountSlider(
                            title: "월 저축 계획",
                            value: $monthlyDeposit,
                            minValue: 0,
                            maxValue: 10_000_000,
                            step: 100_000
                        )
                        PercentSlider(title: "연평균 수익률", value: $annualReturnRate)
                    }

                    SectionCard {
                        PaydayGridPicker(selectedDay: $paydayOfMonth)
                    }

                    SectionCard {
                        Text("화면 모드")
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryText)
                        Picker("화면 모드", selection: $viewModel.colorScheme) {
                            ForEach(AppColorScheme.allCases) { scheme in
                                Text(scheme.label).tag(scheme)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    SectionCard {
                        Text("위젯")
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryText)
                        Text("홈 화면에서 위젯 추가\n→ 1억 계산기 검색")
                            .font(.system(.footnote, design: .rounded))
                            .foregroundStyle(AppTheme.primaryText)
                    }

                    SectionCard {
                        Text("앱 정보")
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryText)
                        HStack {
                            Text("버전")
                                .font(.system(.footnote, design: .rounded))
                                .foregroundStyle(AppTheme.secondaryText)
                            Spacer()
                            Text("1.0.0")
                                .font(.system(.footnote, design: .rounded, weight: .medium))
                                .foregroundStyle(AppTheme.primaryText)
                        }
                        HStack {
                            Text("데이터")
                                .font(.system(.footnote, design: .rounded))
                                .foregroundStyle(AppTheme.secondaryText)
                            Spacer()
                            Text("이 기기에만 저장")
                                .font(.system(.footnote, design: .rounded, weight: .medium))
                                .foregroundStyle(AppTheme.primaryText)
                        }
                    }

                    Button(role: .destructive) {
                        showResetConfirm = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("모든 데이터 초기화")
                        }
                        .font(.system(.callout, design: .rounded, weight: .medium))
                        .frame(maxWidth: .infinity, minHeight: 48)
                    }
                    .foregroundStyle(AppTheme.danger)
                    .padding(.top, AppTheme.Spacing.m)
                }
                .padding(AppTheme.Spacing.m)
            }
            .background(AppTheme.background)
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("저장", action: save)
                        .fontWeight(.semibold)
                        .disabled(!isValid)
                }
            }
            .onAppear(perform: load)
            .alert("모든 데이터를 지울까요?", isPresented: $showResetConfirm) {
                Button("취소", role: .cancel) {}
                Button("초기화", role: .destructive) {
                    viewModel.resetAll()
                    dismiss()
                }
            } message: {
                Text("목표, 현재 금액, 모든 입금 기록이 삭제됩니다. 되돌릴 수 없어요.")
            }
        }
    }

    private var isValid: Bool {
        targetAmount > 0 && currentAmount >= 0 && monthlyDeposit >= 0 && (1...31).contains(paydayOfMonth)
    }

    private func load() {
        let g = viewModel.goal
        targetAmount = g.targetAmount
        currentAmount = g.currentAmount
        monthlyDeposit = g.monthlyDeposit
        paydayOfMonth = g.paydayOfMonth
        annualReturnRate = g.annualReturnRate
    }

    private func save() {
        var g = viewModel.goal
        g.targetAmount = targetAmount
        g.currentAmount = currentAmount
        g.monthlyDeposit = monthlyDeposit
        g.paydayOfMonth = paydayOfMonth
        g.annualReturnRate = annualReturnRate
        viewModel.updateGoal(g)
        dismiss()
    }
}
