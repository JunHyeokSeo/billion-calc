import Foundation

public struct SharedStorage {

    public static let appGroupIdentifier = "group.com.westjh.billion-calc"

    public static let defaultAppGroup: UserDefaults = {
        UserDefaults(suiteName: appGroupIdentifier) ?? .standard
    }()

    enum Key {
        static let savingsGoal = "savingsGoal"
        static let monthlyDeposits = "monthlyDeposits"
        static let recentMotivationTemplates = "recentMotivationTemplates"
        static let onboardingCompleted = "onboardingCompleted"
        static let lastConfirmedMonth = "lastConfirmedMonth"
        static let monthlyIncomeForRatio = "monthlyIncomeForRatio"
    }

    public let defaults: UserDefaults

    public init(defaults: UserDefaults = SharedStorage.defaultAppGroup) {
        self.defaults = defaults
    }

    // MARK: - SavingsGoal

    public func loadGoal() -> SavingsGoal? {
        guard let data = defaults.data(forKey: Key.savingsGoal) else { return nil }
        return try? JSONDecoder().decode(SavingsGoal.self, from: data)
    }

    public func saveGoal(_ goal: SavingsGoal) {
        guard let data = try? JSONEncoder().encode(goal) else { return }
        defaults.set(data, forKey: Key.savingsGoal)
    }

    // MARK: - Monthly deposits

    public func loadDeposits() -> [MonthlyDeposit] {
        guard let data = defaults.data(forKey: Key.monthlyDeposits) else { return [] }
        return (try? JSONDecoder().decode([MonthlyDeposit].self, from: data)) ?? []
    }

    public func saveDeposits(_ deposits: [MonthlyDeposit]) {
        guard let data = try? JSONEncoder().encode(deposits) else { return }
        defaults.set(data, forKey: Key.monthlyDeposits)
    }

    @discardableResult
    public func upsertDeposit(_ deposit: MonthlyDeposit) -> [MonthlyDeposit] {
        var list = loadDeposits()
        if let idx = list.firstIndex(where: { $0.yearMonth == deposit.yearMonth }) {
            list[idx] = deposit
        } else {
            list.append(deposit)
        }
        list.sort { $0.yearMonth < $1.yearMonth }
        saveDeposits(list)
        defaults.set(deposit.yearMonth, forKey: Key.lastConfirmedMonth)
        return list
    }

    public func deposit(forYearMonth yearMonth: String) -> MonthlyDeposit? {
        loadDeposits().first(where: { $0.yearMonth == yearMonth })
    }

    public var lastConfirmedMonth: String? {
        get { defaults.string(forKey: Key.lastConfirmedMonth) }
        nonmutating set { defaults.set(newValue, forKey: Key.lastConfirmedMonth) }
    }

    // MARK: - Recent motivation templates (for diversity)

    public var recentMotivationTemplates: [String] {
        get { defaults.stringArray(forKey: Key.recentMotivationTemplates) ?? [] }
        nonmutating set { defaults.set(newValue, forKey: Key.recentMotivationTemplates) }
    }

    public func pushRecentMotivation(_ template: String, maxKept: Int = 20) {
        var list = recentMotivationTemplates
        list.removeAll { $0 == template }
        list.insert(template, at: 0)
        if list.count > maxKept { list = Array(list.prefix(maxKept)) }
        recentMotivationTemplates = list
    }

    // MARK: - Onboarding

    public var onboardingCompleted: Bool {
        get { defaults.bool(forKey: Key.onboardingCompleted) }
        nonmutating set { defaults.set(newValue, forKey: Key.onboardingCompleted) }
    }

    // MARK: - Monthly income (for warning ratio)

    public var monthlyIncomeForRatio: Decimal? {
        get {
            guard defaults.object(forKey: Key.monthlyIncomeForRatio) != nil else { return nil }
            let s = defaults.string(forKey: Key.monthlyIncomeForRatio) ?? ""
            return Decimal(string: s)
        }
        nonmutating set {
            if let value = newValue {
                defaults.set("\(value)", forKey: Key.monthlyIncomeForRatio)
            } else {
                defaults.removeObject(forKey: Key.monthlyIncomeForRatio)
            }
        }
    }

    // MARK: - Reset (debug/onboarding)

    public func resetAll() {
        defaults.removeObject(forKey: Key.savingsGoal)
        defaults.removeObject(forKey: Key.monthlyDeposits)
        defaults.removeObject(forKey: Key.recentMotivationTemplates)
        defaults.removeObject(forKey: Key.onboardingCompleted)
        defaults.removeObject(forKey: Key.lastConfirmedMonth)
        defaults.removeObject(forKey: Key.monthlyIncomeForRatio)
    }
}

public struct WidgetSnapshot: Sendable, Equatable {
    public var progress: Double
    public var daysRemaining: Int
    public var monthsRemaining: Int
    public var currentAmount: Decimal
    public var targetAmount: Decimal
    public var motivationText: String
    public var generatedAt: Date
    public var isImpossible: Bool

    public init(
        progress: Double,
        daysRemaining: Int,
        monthsRemaining: Int,
        currentAmount: Decimal,
        targetAmount: Decimal,
        motivationText: String,
        generatedAt: Date,
        isImpossible: Bool
    ) {
        self.progress = progress
        self.daysRemaining = daysRemaining
        self.monthsRemaining = monthsRemaining
        self.currentAmount = currentAmount
        self.targetAmount = targetAmount
        self.motivationText = motivationText
        self.generatedAt = generatedAt
        self.isImpossible = isImpossible
    }

    public static func build(from storage: SharedStorage, now: Date = Date()) -> WidgetSnapshot? {
        guard let goal = storage.loadGoal() else { return nil }

        let monthsResult = SavingsCalculator.monthsUntilGoal(goal)
        let months: Int
        var isImpossible = false
        switch monthsResult {
        case .success(let m): months = m
        case .failure:
            months = 0
            isImpossible = true
        }

        let projected = SavingsCalculator.projectedCompletionDate(
            from: now, paydayOfMonth: goal.paydayOfMonth, months: months
        ) ?? now
        let days = SavingsCalculator.daysRemaining(until: projected, from: now)

        let progress = SavingsCalculator.progress(current: goal.currentAmount, target: goal.targetAmount)

        let ctx = MotivationContext(
            progress: progress,
            daysRemaining: days,
            monthsRemaining: months,
            totalSaved: goal.currentAmount,
            isPaydayToday: false,
            monthsSinceStart: monthsSince(start: goal.startDate, now: now),
            annualReturnRate: goal.annualReturnRate,
            isImpossible: isImpossible
        )
        let recent = Set(storage.recentMotivationTemplates)
        let msg = MotivationLibrary.pick(context: ctx, excluding: recent, widgetOnly: true)

        return WidgetSnapshot(
            progress: progress,
            daysRemaining: days,
            monthsRemaining: months,
            currentAmount: goal.currentAmount,
            targetAmount: goal.targetAmount,
            motivationText: msg,
            generatedAt: now,
            isImpossible: isImpossible
        )
    }

    private static func monthsSince(start: Date, now: Date) -> Int {
        let cal = SavingsCalculator.koreanCalendar
        let comps = cal.dateComponents([.month], from: start, to: now)
        return max(0, comps.month ?? 0)
    }
}
