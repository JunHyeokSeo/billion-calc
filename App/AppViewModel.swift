import Foundation
import SwiftUI
import WidgetKit
import BillionCalcCore

@MainActor
final class AppViewModel: ObservableObject {
    @Published private(set) var goal: SavingsGoal
    @Published private(set) var deposits: [MonthlyDeposit]
    @Published var onboardingCompleted: Bool

    private let storage: SharedStorage

    init(storage: SharedStorage = SharedStorage()) {
        self.storage = storage
        self.goal = storage.loadGoal() ?? .empty
        self.deposits = storage.loadDeposits()
        self.onboardingCompleted = storage.onboardingCompleted
    }

    // MARK: - Computed

    var monthsResult: Result<Int, CalculationError> {
        SavingsCalculator.monthsUntilGoal(goal)
    }

    var monthsRemaining: Int {
        switch monthsResult {
        case .success(let m): return m
        case .failure: return 0
        }
    }

    var isImpossible: Bool {
        if case .failure(.impossible) = monthsResult { return true }
        return false
    }

    var isInvalidInput: Bool {
        if case .failure(.invalidInput) = monthsResult { return true }
        return false
    }

    var progress: Double {
        SavingsCalculator.progress(current: goal.currentAmount, target: goal.targetAmount)
    }

    var isAchieved: Bool { progress >= 1.0 }

    var projectedDate: Date {
        SavingsCalculator.projectedCompletionDate(
            paydayOfMonth: goal.paydayOfMonth,
            months: monthsRemaining
        ) ?? Date()
    }

    var daysRemaining: Int {
        SavingsCalculator.daysRemaining(until: projectedDate)
    }

    var currentYearMonth: String {
        MonthlyDeposit.key(for: Date())
    }

    var currentMonthDeposit: MonthlyDeposit? {
        deposits.first(where: { $0.yearMonth == currentYearMonth })
    }

    var currentMonthConfirmed: Bool {
        currentMonthDeposit != nil
    }

    var monthsSinceStart: Int {
        let cal = SavingsCalculator.koreanCalendar
        let comps = cal.dateComponents([.month], from: goal.startDate, to: Date())
        return max(0, comps.month ?? 0)
    }

    var motivationContext: MotivationContext {
        MotivationContext(
            progress: progress,
            daysRemaining: daysRemaining,
            monthsRemaining: monthsRemaining,
            totalSaved: goal.currentAmount,
            isPaydayToday: isPaydayToday,
            monthsSinceStart: monthsSinceStart,
            lastDepositDelta: currentMonthDeposit?.delta,
            annualReturnRate: goal.annualReturnRate,
            isImpossible: isImpossible,
            paydayCount: monthsSinceStart
        )
    }

    var isPaydayToday: Bool {
        let cal = SavingsCalculator.koreanCalendar
        let day = cal.component(.day, from: Date())
        return day == goal.paydayOfMonth
    }

    func motivation() -> String {
        let recent = Set(storage.recentMotivationTemplates)
        let msg = MotivationLibrary.pick(context: motivationContext, excluding: recent)
        storage.pushRecentMotivation(msg)
        return msg
    }

    // MARK: - What-if simulation

    func simulateMonths(withMonthlyDeposit override: Decimal) -> Int? {
        let result = SavingsCalculator.monthsUntilGoal(
            target: goal.targetAmount,
            current: goal.currentAmount,
            monthlyDeposit: override,
            annualReturnRate: goal.annualReturnRate
        )
        if case .success(let m) = result { return m }
        return nil
    }

    // MARK: - Intents

    func completeOnboarding(with newGoal: SavingsGoal, monthlyIncome: Decimal? = nil) {
        var g = newGoal
        g.updatedAt = Date()
        g.startDate = Date()
        goal = g
        storage.saveGoal(g)
        storage.monthlyIncomeForRatio = monthlyIncome
        storage.onboardingCompleted = true
        onboardingCompleted = true
        reloadWidget()
    }

    func updateGoal(_ updated: SavingsGoal) {
        var g = updated
        g.updatedAt = Date()
        goal = g
        storage.saveGoal(g)
        reloadWidget()
    }

    func confirmDeposit(forYearMonth yearMonth: String, actualAmount: Decimal) {
        let previous = deposits.first(where: { $0.yearMonth == yearMonth })
        let delta = actualAmount - (previous?.actualAmount ?? 0)

        let deposit = MonthlyDeposit(
            yearMonth: yearMonth,
            actualAmount: actualAmount,
            plannedAmount: goal.monthlyDeposit
        )
        deposits = storage.upsertDeposit(deposit)

        var updated = goal
        updated.currentAmount = max(0, updated.currentAmount + delta)
        updated.updatedAt = Date()
        goal = updated
        storage.saveGoal(updated)
        reloadWidget()
    }

    func resetAll() {
        storage.resetAll()
        goal = .empty
        deposits = []
        onboardingCompleted = false
        reloadWidget()
    }

    private func reloadWidget() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
