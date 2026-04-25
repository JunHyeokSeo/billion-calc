import Foundation

public enum CalculationError: Error, Equatable, Sendable {
    case invalidInput
    case impossible
}

public struct SavingsCalculator: Sendable {

    public static var koreanCalendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Asia/Seoul") ?? .current
        return cal
    }

    public static func monthsUntilGoal(
        target: Decimal,
        current: Decimal,
        monthlyDeposit: Decimal,
        annualReturnRate: Double
    ) -> Result<Int, CalculationError> {
        guard target > 0 else { return .failure(.invalidInput) }
        guard monthlyDeposit >= 0 else { return .failure(.invalidInput) }
        guard current >= 0 else { return .failure(.invalidInput) }
        guard annualReturnRate >= 0 else { return .failure(.invalidInput) }

        if current >= target { return .success(0) }

        let P = (current as NSDecimalNumber).doubleValue
        let G = (target as NSDecimalNumber).doubleValue
        let M = (monthlyDeposit as NSDecimalNumber).doubleValue
        let r = annualReturnRate / 100.0 / 12.0

        if r == 0 {
            guard M > 0 else { return .failure(.impossible) }
            let n = ceil((G - P) / M)
            return .success(Int(n))
        }

        if M == 0 && P == 0 { return .failure(.impossible) }

        let num = G + M / r
        let den = P + M / r
        guard den > 0 else { return .failure(.impossible) }

        let ratio = num / den
        if ratio <= 1 { return .success(0) }

        let n = log(ratio) / log(1 + r)
        guard n.isFinite, n >= 0 else { return .failure(.impossible) }

        return .success(Int(ceil(n)))
    }

    public static func monthsUntilGoal(_ goal: SavingsGoal) -> Result<Int, CalculationError> {
        monthsUntilGoal(
            target: goal.targetAmount,
            current: goal.currentAmount,
            monthlyDeposit: goal.monthlyDeposit,
            annualReturnRate: goal.annualReturnRate
        )
    }

    public static func projectedCompletionDate(
        from today: Date = Date(),
        paydayOfMonth: Int,
        months: Int,
        calendar: Calendar = SavingsCalculator.koreanCalendar
    ) -> Date? {
        guard months >= 0 else { return nil }
        let clampedPayday = max(1, min(31, paydayOfMonth))

        let comps = calendar.dateComponents([.year, .month, .day], from: today)
        guard let year = comps.year, let month = comps.month, let day = comps.day else { return nil }

        var nextPay = DateComponents()
        nextPay.year = year
        nextPay.month = month
        nextPay.day = clampedPayday

        guard var date = calendar.date(from: nextPay) else { return nil }
        if day > clampedPayday {
            date = calendar.date(byAdding: .month, value: 1, to: date) ?? date
        }

        let stepsFromNextPay = max(0, months - 1)
        return calendar.date(byAdding: .month, value: stepsFromNextPay, to: date)
    }

    public static func progress(current: Decimal, target: Decimal) -> Double {
        guard target > 0 else { return 0 }
        let c = (current as NSDecimalNumber).doubleValue
        let t = (target as NSDecimalNumber).doubleValue
        return min(1.0, max(0.0, c / t))
    }

    public static func daysRemaining(until target: Date, from today: Date = Date(), calendar: Calendar = SavingsCalculator.koreanCalendar) -> Int {
        let start = calendar.startOfDay(for: today)
        let end = calendar.startOfDay(for: target)
        let comps = calendar.dateComponents([.day], from: start, to: end)
        return max(0, comps.day ?? 0)
    }

    public static func futureValue(
        principal: Decimal,
        monthlyDeposit: Decimal,
        annualReturnRate: Double,
        months: Int
    ) -> Decimal {
        guard months >= 0 else { return principal }
        let P = (principal as NSDecimalNumber).doubleValue
        let M = (monthlyDeposit as NSDecimalNumber).doubleValue
        let r = annualReturnRate / 100.0 / 12.0
        let n = Double(months)

        let fv: Double
        if r == 0 {
            fv = P + M * n
        } else {
            let growth = pow(1 + r, n)
            fv = P * growth + M * (growth - 1) / r
        }
        return Decimal(fv)
    }
}
