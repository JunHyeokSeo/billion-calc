import Foundation

public struct MonthlyDeposit: Codable, Equatable, Hashable, Sendable {
    public let yearMonth: String
    public var actualAmount: Decimal
    public var plannedAmount: Decimal
    public var confirmedAt: Date

    public init(yearMonth: String, actualAmount: Decimal, plannedAmount: Decimal, confirmedAt: Date = Date()) {
        self.yearMonth = yearMonth
        self.actualAmount = actualAmount
        self.plannedAmount = plannedAmount
        self.confirmedAt = confirmedAt
    }

    public var delta: Decimal { actualAmount - plannedAmount }

    public static func key(for date: Date, calendar: Calendar = SavingsCalculator.koreanCalendar) -> String {
        let comps = calendar.dateComponents([.year, .month], from: date)
        return String(format: "%04d-%02d", comps.year ?? 0, comps.month ?? 0)
    }
}
