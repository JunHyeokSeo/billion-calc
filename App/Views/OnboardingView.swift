import SwiftUI
import BillionCalcCore

struct OnboardingView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @State private var pageIndex: Int = 0

    @State private var targetAmount: Decimal = 100_000_000
    @State private var currentAmount: Decimal = 0
    @State private var monthlyDeposit: Decimal = 1_500_000
    @State private var paydayOfMonth: Int = 25
    @State private var annualReturnRate: Double = 0
    @State private var monthlyIncome: Decimal = 3_000_000

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $pageIndex) {
                welcomePage
                    .tag(0)
                explainPage
                    .tag(1)
                inputPage
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .indexViewStyle(.page(backgroundDisplayMode: .never))

            HStack(spacing: AppTheme.Spacing.s) {
                ForEach(0..<3) { i in
                    Capsule()
                        .fill(i == pageIndex ? AppTheme.accent : AppTheme.cardBackground)
                        .frame(width: i == pageIndex ? 24 : 8, height: 8)
                        .animation(.spring(duration: 0.3), value: pageIndex)
                }
            }
            .padding(.vertical, AppTheme.Spacing.m)

            bottomBar
        }
        .background(AppTheme.background)
    }

    // MARK: - Pages

    private var welcomePage: some View {
        VStack(spacing: AppTheme.Spacing.l) {
            Spacer()
            Image(systemName: "wonsign.circle.fill")
                .font(.system(size: 120, weight: .bold))
                .foregroundStyle(AppTheme.accent)
            VStack(spacing: AppTheme.Spacing.s) {
                Text("1억 달성일,\n정확히 언제일까?")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.primaryText)
                Text("월급과 저축액만 입력하면\n목표일을 알려드립니다")
                    .font(.system(.title3, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .padding(.horizontal, AppTheme.Spacing.l)
            Spacer()
            Spacer()
        }
    }

    private var explainPage: some View {
        VStack(spacing: AppTheme.Spacing.l) {
            Spacer()
            VStack(spacing: AppTheme.Spacing.m) {
                featureRow(icon: "calendar.badge.clock", title: "달성까지 남은 개월", description: "목표일까지 남은 시간을 매일 확인하세요")
                featureRow(icon: "chart.bar.fill", title: "진행률 시각화", description: "얼마나 왔는지, 얼마나 남았는지 한눈에")
                featureRow(icon: "hand.draw.fill", title: "월 입금 드래그 조정", description: "실제 입금액을 빠르게 반영, 목표일 자동 재계산")
                featureRow(icon: "rectangle.3.group.fill", title: "위젯으로 매일 확인", description: "홈 화면 위젯으로 동기부여 유지")
            }
            .padding(.horizontal, AppTheme.Spacing.l)
            Spacer()
        }
    }

    private var inputPage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.l) {
                Text("목표를 설정해볼게요")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(AppTheme.primaryText)
                    .padding(.top, AppTheme.Spacing.l)

                SectionCard {
                    TargetAmountSlider(value: $targetAmount)
                }

                SectionCard {
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
                }

                SectionCard {
                    PaydayGridPicker(selectedDay: $paydayOfMonth)
                }

                SectionCard {
                    Text("선택 입력")
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)
                    PercentSlider(title: "연평균 수익률 (주식/예적금)", value: $annualReturnRate)
                    AmountSlider(
                        title: "월급 (저축 비율 경고용)",
                        value: $monthlyIncome,
                        minValue: 0,
                        maxValue: 20_000_000,
                        step: 500_000
                    )
                }
            }
            .padding(.horizontal, AppTheme.Spacing.l)
            .padding(.bottom, AppTheme.Spacing.xl)
        }
    }

    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.m) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(AppTheme.accent)
                .frame(width: 48)
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(title)
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryText)
                Text(description)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(AppTheme.secondaryText)
            }
            Spacer()
        }
    }

    // MARK: - Bottom bar

    private var bottomBar: some View {
        VStack(spacing: AppTheme.Spacing.s) {
            if pageIndex == 2 {
                PrimaryButton(title: "시작하기", action: start, isEnabled: inputIsValid)
            } else {
                PrimaryButton(title: "다음") {
                    withAnimation(.spring(duration: 0.3)) {
                        pageIndex = min(pageIndex + 1, 2)
                    }
                }
            }
            Button("이전") {
                withAnimation(.spring(duration: 0.3)) {
                    pageIndex = max(pageIndex - 1, 0)
                }
            }
            .font(.system(.callout, design: .rounded))
            .foregroundStyle(AppTheme.secondaryText)
            .opacity(pageIndex > 0 ? 1 : 0)
            .disabled(pageIndex == 0)
            .accessibilityHidden(pageIndex == 0)
        }
        .padding(.horizontal, AppTheme.Spacing.l)
        .padding(.bottom, AppTheme.Spacing.l)
    }

    private var inputIsValid: Bool {
        targetAmount > 0 && currentAmount >= 0 && monthlyDeposit >= 0 && (1...31).contains(paydayOfMonth)
    }

    private func start() {
        let goal = SavingsGoal(
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            monthlyDeposit: monthlyDeposit,
            paydayOfMonth: paydayOfMonth,
            annualReturnRate: annualReturnRate
        )
        viewModel.completeOnboarding(with: goal, monthlyIncome: monthlyIncome > 0 ? monthlyIncome : nil)
    }
}
