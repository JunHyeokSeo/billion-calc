import XCTest
@testable import BillionCalcCore

final class SavingsCalculatorTests: XCTestCase {

    func test_alreadyAchieved_returnsZero() throws {
        let r = SavingsCalculator.monthsUntilGoal(
            target: 100_000_000, current: 100_000_000,
            monthlyDeposit: 0, annualReturnRate: 0
        )
        XCTAssertEqual(try r.get(), 0)
    }

    func test_overshot_returnsZero() throws {
        let r = SavingsCalculator.monthsUntilGoal(
            target: 100_000_000, current: 200_000_000,
            monthlyDeposit: 0, annualReturnRate: 0
        )
        XCTAssertEqual(try r.get(), 0)
    }

    func test_linear_noReturn_exact() throws {
        let r = SavingsCalculator.monthsUntilGoal(
            target: 10_000_000, current: 0,
            monthlyDeposit: 1_000_000, annualReturnRate: 0
        )
        XCTAssertEqual(try r.get(), 10)
    }

    func test_linear_partialPrincipal() throws {
        let r = SavingsCalculator.monthsUntilGoal(
            target: 10_000_000, current: 3_500_000,
            monthlyDeposit: 1_000_000, annualReturnRate: 0
        )
        XCTAssertEqual(try r.get(), 7)
    }

    func test_compound_5percent_1억() throws {
        let r = SavingsCalculator.monthsUntilGoal(
            target: 100_000_000, current: 0,
            monthlyDeposit: 1_000_000, annualReturnRate: 5.0
        )
        let months = try r.get()
        XCTAssertGreaterThanOrEqual(months, 83)
        XCTAssertLessThanOrEqual(months, 85)
    }

    func test_compound_withExistingCapital() throws {
        let r = SavingsCalculator.monthsUntilGoal(
            target: 100_000_000, current: 30_000_000,
            monthlyDeposit: 1_000_000, annualReturnRate: 5.0
        )
        let months = try r.get()
        XCTAssertGreaterThanOrEqual(months, 54)
        XCTAssertLessThanOrEqual(months, 57)
    }

    func test_compoundOnly_noDeposit() throws {
        let r = SavingsCalculator.monthsUntilGoal(
            target: 1_000_000, current: 500_000,
            monthlyDeposit: 0, annualReturnRate: 10.0
        )
        let months = try r.get()
        XCTAssertGreaterThan(months, 0)
        XCTAssertLessThan(months, 120)
    }

    func test_impossible_allZero() {
        let r = SavingsCalculator.monthsUntilGoal(
            target: 1_000_000, current: 0,
            monthlyDeposit: 0, annualReturnRate: 0
        )
        XCTAssertEqual(r, .failure(.impossible))
    }

    func test_impossible_zeroPrincipalZeroDepositWithReturn() {
        let r = SavingsCalculator.monthsUntilGoal(
            target: 1_000_000, current: 0,
            monthlyDeposit: 0, annualReturnRate: 5.0
        )
        XCTAssertEqual(r, .failure(.impossible))
    }

    func test_invalid_negativeDeposit() {
        let r = SavingsCalculator.monthsUntilGoal(
            target: 1_000_000, current: 0,
            monthlyDeposit: -1, annualReturnRate: 0
        )
        XCTAssertEqual(r, .failure(.invalidInput))
    }

    func test_invalid_zeroTarget() {
        let r = SavingsCalculator.monthsUntilGoal(
            target: 0, current: 0,
            monthlyDeposit: 1_000_000, annualReturnRate: 0
        )
        XCTAssertEqual(r, .failure(.invalidInput))
    }

    func test_invalid_negativeReturnRate() {
        let r = SavingsCalculator.monthsUntilGoal(
            target: 1_000_000, current: 0,
            monthlyDeposit: 100, annualReturnRate: -1.0
        )
        XCTAssertEqual(r, .failure(.invalidInput))
    }

    func test_progress_basicCases() {
        XCTAssertEqual(SavingsCalculator.progress(current: 50, target: 100), 0.5, accuracy: 0.0001)
        XCTAssertEqual(SavingsCalculator.progress(current: 0, target: 100), 0.0, accuracy: 0.0001)
        XCTAssertEqual(SavingsCalculator.progress(current: 150, target: 100), 1.0, accuracy: 0.0001)
        XCTAssertEqual(SavingsCalculator.progress(current: 50, target: 0), 0.0, accuracy: 0.0001)
    }

    func test_projectedDate_beforePayday() {
        let cal = SavingsCalculator.koreanCalendar
        var comps = DateComponents()
        comps.year = 2026; comps.month = 4; comps.day = 10
        let today = cal.date(from: comps)!

        let projected = SavingsCalculator.projectedCompletionDate(
            from: today, paydayOfMonth: 25, months: 12
        )!
        let p = cal.dateComponents([.year, .month, .day], from: projected)
        XCTAssertEqual(p.year, 2027)
        XCTAssertEqual(p.month, 3)
        XCTAssertEqual(p.day, 25)
    }

    func test_projectedDate_afterPayday_rollsForward() {
        let cal = SavingsCalculator.koreanCalendar
        var comps = DateComponents()
        comps.year = 2026; comps.month = 4; comps.day = 26
        let today = cal.date(from: comps)!

        let projected = SavingsCalculator.projectedCompletionDate(
            from: today, paydayOfMonth: 25, months: 12
        )!
        let p = cal.dateComponents([.year, .month, .day], from: projected)
        XCTAssertEqual(p.year, 2027)
        XCTAssertEqual(p.month, 4)
        XCTAssertEqual(p.day, 25)
    }

    func test_futureValue_linear() {
        let fv = SavingsCalculator.futureValue(
            principal: 0, monthlyDeposit: 1_000_000,
            annualReturnRate: 0, months: 12
        )
        let expected = Decimal(12_000_000)
        let diff = abs((fv - expected as NSDecimalNumber).doubleValue)
        XCTAssertLessThan(diff, 1.0)
    }

    func test_futureValue_compound_reachesGoal() {
        let fv = SavingsCalculator.futureValue(
            principal: 0, monthlyDeposit: 1_000_000,
            annualReturnRate: 5.0, months: 84
        )
        let target = Decimal(100_000_000)
        XCTAssertGreaterThanOrEqual(fv, target)
    }

    func test_monthlyDepositKey_format() {
        let cal = SavingsCalculator.koreanCalendar
        var comps = DateComponents()
        comps.year = 2026; comps.month = 4; comps.day = 24
        let date = cal.date(from: comps)!
        XCTAssertEqual(MonthlyDeposit.key(for: date, calendar: cal), "2026-04")
    }
}
