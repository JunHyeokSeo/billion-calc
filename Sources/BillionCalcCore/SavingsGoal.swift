import Foundation

public struct SavingsGoal: Codable, Equatable, Sendable {
    public var targetAmount: Decimal
    public var currentAmount: Decimal
    public var monthlyDeposit: Decimal
    public var paydayOfMonth: Int
    public var annualReturnRate: Double
    public var startDate: Date
    public var updatedAt: Date

    public init(
        targetAmount: Decimal,
        currentAmount: Decimal,
        monthlyDeposit: Decimal,
        paydayOfMonth: Int,
        annualReturnRate: Double = 0.0,
        startDate: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.monthlyDeposit = monthlyDeposit
        self.paydayOfMonth = max(1, min(31, paydayOfMonth))
        self.annualReturnRate = max(0, annualReturnRate)
        self.startDate = startDate
        self.updatedAt = updatedAt
    }

    public static let empty = SavingsGoal(
        targetAmount: 100_000_000,
        currentAmount: 0,
        monthlyDeposit: 1_000_000,
        paydayOfMonth: 25,
        annualReturnRate: 0
    )
}
