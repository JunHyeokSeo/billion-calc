import Foundation
import BillionCalcCore

// Minimal XCTest-free harness for Command Line Tools environments
// (Xcode not required). Run with: swift run BillionCalcVerify

var passed = 0
var failed = 0

@discardableResult
func expect<T: Equatable>(_ actual: T, _ expected: T, _ label: String, file: String = #file, line: Int = #line) -> Bool {
    if actual == expected {
        passed += 1
        print("  ✓ \(label)")
        return true
    } else {
        failed += 1
        print("  ✗ \(label)")
        print("    expected: \(expected)")
        print("    actual:   \(actual)")
        print("    at \((file as NSString).lastPathComponent):\(line)")
        return false
    }
}

func expectInRange(_ actual: Int, _ range: ClosedRange<Int>, _ label: String, file: String = #file, line: Int = #line) {
    if range.contains(actual) {
        passed += 1
        print("  ✓ \(label) (= \(actual))")
    } else {
        failed += 1
        print("  ✗ \(label): expected in \(range), got \(actual)")
        print("    at \((file as NSString).lastPathComponent):\(line)")
    }
}

func section(_ title: String) {
    print("\n── \(title) ──")
}

// ────────────────────────────────────────────────────────
// monthsUntilGoal
// ────────────────────────────────────────────────────────

section("monthsUntilGoal — 기본")

do {
    let r = SavingsCalculator.monthsUntilGoal(target: 100_000_000, current: 100_000_000, monthlyDeposit: 0, annualReturnRate: 0)
    expect(try? r.get(), 0, "이미 달성 → 0개월")
}

do {
    let r = SavingsCalculator.monthsUntilGoal(target: 100_000_000, current: 200_000_000, monthlyDeposit: 0, annualReturnRate: 0)
    expect(try? r.get(), 0, "목표 초과 보유 → 0개월")
}

do {
    let r = SavingsCalculator.monthsUntilGoal(target: 10_000_000, current: 0, monthlyDeposit: 1_000_000, annualReturnRate: 0)
    expect(try? r.get(), 10, "단리 0%: 0 → 1천만 / 월 100만 = 10개월")
}

do {
    let r = SavingsCalculator.monthsUntilGoal(target: 10_000_000, current: 3_500_000, monthlyDeposit: 1_000_000, annualReturnRate: 0)
    expect(try? r.get(), 7, "단리: 350만 원금, 월 100만, 10M 목표 → 7개월")
}

section("monthsUntilGoal — 복리")

do {
    let r = SavingsCalculator.monthsUntilGoal(target: 100_000_000, current: 0, monthlyDeposit: 1_000_000, annualReturnRate: 5.0)
    expectInRange(try! r.get(), 83...85, "연 5% 복리, 월 100만, 0→1억")
}

do {
    let r = SavingsCalculator.monthsUntilGoal(target: 100_000_000, current: 30_000_000, monthlyDeposit: 1_000_000, annualReturnRate: 5.0)
    expectInRange(try! r.get(), 54...57, "연 5% 복리, 월 100만, 3천만→1억")
}

do {
    let r = SavingsCalculator.monthsUntilGoal(target: 1_000_000, current: 500_000, monthlyDeposit: 0, annualReturnRate: 10.0)
    let months = try! r.get()
    expectInRange(months, 1...120, "복리만(입금 0): 50만→100만, 연 10%")
}

section("monthsUntilGoal — 실패 케이스")

do {
    let r = SavingsCalculator.monthsUntilGoal(target: 1_000_000, current: 0, monthlyDeposit: 0, annualReturnRate: 0)
    expect(r, .failure(.impossible), "모두 0 → 불가능")
}

do {
    let r = SavingsCalculator.monthsUntilGoal(target: 1_000_000, current: 0, monthlyDeposit: 0, annualReturnRate: 5.0)
    expect(r, .failure(.impossible), "원금·입금 0인데 수익률만 → 불가능")
}

do {
    let r = SavingsCalculator.monthsUntilGoal(target: 1_000_000, current: 0, monthlyDeposit: -1, annualReturnRate: 0)
    expect(r, .failure(.invalidInput), "음수 입금 → invalidInput")
}

do {
    let r = SavingsCalculator.monthsUntilGoal(target: 0, current: 0, monthlyDeposit: 1_000_000, annualReturnRate: 0)
    expect(r, .failure(.invalidInput), "목표 0 → invalidInput")
}

do {
    let r = SavingsCalculator.monthsUntilGoal(target: 1_000_000, current: 0, monthlyDeposit: 100, annualReturnRate: -1.0)
    expect(r, .failure(.invalidInput), "음수 수익률 → invalidInput")
}

// ────────────────────────────────────────────────────────
// progress
// ────────────────────────────────────────────────────────

section("progress")

expect(SavingsCalculator.progress(current: 50, target: 100), 0.5, "50/100 = 0.5")
expect(SavingsCalculator.progress(current: 0, target: 100), 0.0, "0/100 = 0")
expect(SavingsCalculator.progress(current: 150, target: 100), 1.0, "150/100 = 1.0 (clamped)")
expect(SavingsCalculator.progress(current: 50, target: 0), 0.0, "target 0 → 0 (안전)")

// ────────────────────────────────────────────────────────
// projectedCompletionDate
// ────────────────────────────────────────────────────────

section("projectedCompletionDate")

do {
    let cal = SavingsCalculator.koreanCalendar
    var comps = DateComponents()
    comps.year = 2026; comps.month = 4; comps.day = 10
    let today = cal.date(from: comps)!

    let projected = SavingsCalculator.projectedCompletionDate(from: today, paydayOfMonth: 25, months: 12)!
    let p = cal.dateComponents([.year, .month, .day], from: projected)
    expect(p.year, 2027, "2026-04-10 기준 12개월 → 연도 2027")
    expect(p.month, 3, "2026-04-10 기준 12개월 → 3월 (4월 25일이 1번째)")
    expect(p.day, 25, "월급일 25일 고정")
}

do {
    let cal = SavingsCalculator.koreanCalendar
    var comps = DateComponents()
    comps.year = 2026; comps.month = 4; comps.day = 26
    let today = cal.date(from: comps)!

    let projected = SavingsCalculator.projectedCompletionDate(from: today, paydayOfMonth: 25, months: 12)!
    let p = cal.dateComponents([.year, .month, .day], from: projected)
    expect(p.year, 2027, "월급일 지난 뒤: 다음 달부터 카운트")
    expect(p.month, 4, "2026-04-26 기준 12개월 → 2027-04")
}

// ────────────────────────────────────────────────────────
// futureValue
// ────────────────────────────────────────────────────────

section("futureValue")

do {
    let fv = SavingsCalculator.futureValue(principal: 0, monthlyDeposit: 1_000_000, annualReturnRate: 0, months: 12)
    let diff = abs((fv - Decimal(12_000_000) as NSDecimalNumber).doubleValue)
    if diff < 1.0 {
        passed += 1
        print("  ✓ 월 100만, 12개월 단리 = 1200만원 (diff=\(diff))")
    } else {
        failed += 1
        print("  ✗ 월 100만, 12개월 단리 ≠ 1200만원 (diff=\(diff))")
    }
}

do {
    let fv = SavingsCalculator.futureValue(principal: 0, monthlyDeposit: 1_000_000, annualReturnRate: 5.0, months: 84)
    if fv >= Decimal(100_000_000) {
        passed += 1
        print("  ✓ 월 100만, 연 5% 복리, 84개월 → 1억 이상")
    } else {
        failed += 1
        print("  ✗ 84개월 후 1억 미달 (= \(fv))")
    }
}

// ────────────────────────────────────────────────────────
// MonthlyDeposit key
// ────────────────────────────────────────────────────────

section("MonthlyDeposit.key")

do {
    let cal = SavingsCalculator.koreanCalendar
    var comps = DateComponents()
    comps.year = 2026; comps.month = 4; comps.day = 24
    let date = cal.date(from: comps)!
    expect(MonthlyDeposit.key(for: date, calendar: cal), "2026-04", "2026-04-24 → \"2026-04\"")
}

do {
    let deposit = MonthlyDeposit(yearMonth: "2026-04", actualAmount: 800_000, plannedAmount: 1_000_000)
    expect(deposit.delta, Decimal(-200_000), "delta = actual - planned = -20만")
}

// ────────────────────────────────────────────────────────
// MotivationLibrary
// ────────────────────────────────────────────────────────

section("MotivationLibrary — selectCategory")

do {
    let ctx = MotivationContext(progress: 1.0)
    expect(MotivationLibrary.selectCategory(ctx), .milestone100, "progress 1.0 → milestone100")
}

do {
    let ctx = MotivationContext(progress: 0.3, isPaydayToday: true)
    expect(MotivationLibrary.selectCategory(ctx), .payday, "월급날 + delta 없음 → payday")
}

do {
    let ctx = MotivationContext(progress: 0.3, isPaydayToday: true, lastDepositDelta: 500_000)
    expect(MotivationLibrary.selectCategory(ctx), .feedbackOver, "월급날 + delta > 0 → feedbackOver")
}

do {
    let ctx = MotivationContext(progress: 0.3, isPaydayToday: true, lastDepositDelta: 0)
    expect(MotivationLibrary.selectCategory(ctx), .feedbackOnPlan, "월급날 + delta == 0 → feedbackOnPlan")
}

do {
    let ctx = MotivationContext(progress: 0.3, isPaydayToday: true, lastDepositDelta: -100_000)
    expect(MotivationLibrary.selectCategory(ctx), .feedbackUnder, "월급날 + delta < 0 → feedbackUnder")
}

do {
    let ctx = MotivationContext(progress: 0.92)
    expect(MotivationLibrary.selectCategory(ctx), .milestone90, "progress 0.92 → milestone90")
}

do {
    let ctx = MotivationContext(progress: 0.76)
    expect(MotivationLibrary.selectCategory(ctx), .milestone75, "progress 0.76 → milestone75")
}

do {
    let ctx = MotivationContext(progress: 0.5)
    expect(MotivationLibrary.selectCategory(ctx), .milestone50, "progress 0.5 → milestone50")
}

do {
    let ctx = MotivationContext(progress: 0.26)
    expect(MotivationLibrary.selectCategory(ctx), .milestone25, "progress 0.26 → milestone25")
}

do {
    let ctx = MotivationContext(progress: 0.1)
    expect(MotivationLibrary.selectCategory(ctx), .everyday, "progress 0.1 → everyday")
}

do {
    let ctx = MotivationContext(isImpossible: true)
    expect(MotivationLibrary.selectCategory(ctx), .warningImpossible, "isImpossible → 경고")
}

do {
    let ctx = MotivationContext(annualReturnRate: 20)
    expect(MotivationLibrary.selectCategory(ctx), .warningHighRate, "수익률 20% → 경고")
}

do {
    let ctx = MotivationContext(savingToIncomeRatio: 0.7)
    expect(MotivationLibrary.selectCategory(ctx), .warningHighRatio, "저축 비율 70% → 경고")
}

do {
    let ctx = MotivationContext(progress: 0.15, monthsSinceStart: 1)
    expect(MotivationLibrary.selectCategory(ctx), .anniversary1Month, "1개월 경과 → 기념")
}

section("MotivationLibrary — render 치환")

do {
    let out = MotivationLibrary.render("남은 {days}일, {percent}%", substitutions: ["days": "100", "percent": "30"])
    expect(out, "남은 100일, 30%", "{days}·{percent} 치환")
}

do {
    let ctx = MotivationContext(progress: 0.3, daysRemaining: 365, monthsRemaining: 12, totalSaved: 30_000_000, annualReturnRate: 5.0, paydayCount: 3)
    let subs = MotivationLibrary.substitutions(ctx)
    expect(subs["days"], "365", "days substitution")
    expect(subs["months"], "12", "months substitution")
    expect(subs["percent"], "30", "percent substitution")
    expect(subs["count"], "3", "count substitution")
    expect(subs["rate"], "5.0", "rate substitution")
    expect(subs["amount"], "30,000,000", "amount (콤마 포함)")
}

section("MotivationLibrary — pick 종단")

do {
    var rng = SystemRandomNumberGenerator()
    let ctx = MotivationContext(progress: 0.5, daysRemaining: 100, monthsRemaining: 3, totalSaved: 50_000_000)
    let msg = MotivationLibrary.pick(context: ctx, using: &rng)
    if !msg.isEmpty && !msg.contains("{") {
        passed += 1
        print("  ✓ pick() 결과: \(msg)")
    } else {
        failed += 1
        print("  ✗ pick() 결과에 미치환 placeholder: \(msg)")
    }
}

do {
    var rng = SystemRandomNumberGenerator()
    let ctx = MotivationContext(progress: 0.1, daysRemaining: 500, monthsRemaining: 16, totalSaved: 5_000_000)
    let widgetMsg = MotivationLibrary.pick(context: ctx, widgetOnly: true, using: &rng)
    if !widgetMsg.isEmpty && !widgetMsg.contains("{") {
        passed += 1
        print("  ✓ widget-only pick: \(widgetMsg)")
    } else {
        failed += 1
        print("  ✗ widget-only pick 문제: \(widgetMsg)")
    }
}

do {
    let total = MotivationLibrary.all.count
    if total >= 60 {
        passed += 1
        print("  ✓ 멘트 총 \(total)개 (60+ 기준)")
    } else {
        failed += 1
        print("  ✗ 멘트가 너무 적음: \(total)")
    }
}

// ────────────────────────────────────────────────────────
// SharedStorage — 로컬 UserDefaults suite로 격리 테스트
// ────────────────────────────────────────────────────────

section("SharedStorage — 라운드트립")

let testSuite = "com.westjh.billion-calc.verify-\(UUID().uuidString)"
guard let testDefaults = UserDefaults(suiteName: testSuite) else {
    fatalError("UserDefaults suite 생성 실패")
}
testDefaults.removePersistentDomain(forName: testSuite)
let storage = SharedStorage(defaults: testDefaults)

do {
    let goal = SavingsGoal(
        targetAmount: 100_000_000, currentAmount: 15_000_000,
        monthlyDeposit: 1_500_000, paydayOfMonth: 25, annualReturnRate: 5.0
    )
    storage.saveGoal(goal)
    let loaded = storage.loadGoal()
    expect(loaded?.targetAmount, goal.targetAmount, "SavingsGoal 라운드트립 target")
    expect(loaded?.paydayOfMonth, 25, "SavingsGoal 라운드트립 payday")
    expect(loaded?.annualReturnRate, 5.0, "SavingsGoal 라운드트립 return rate")
}

do {
    let d1 = MonthlyDeposit(yearMonth: "2026-04", actualAmount: 1_500_000, plannedAmount: 1_500_000)
    let d2 = MonthlyDeposit(yearMonth: "2026-03", actualAmount: 1_200_000, plannedAmount: 1_500_000)
    storage.upsertDeposit(d1)
    storage.upsertDeposit(d2)

    let list = storage.loadDeposits()
    expect(list.count, 2, "입금 2건 저장")
    expect(list.first?.yearMonth, "2026-03", "정렬 오름차순 확인")
    expect(storage.lastConfirmedMonth, "2026-03", "마지막 저장월 (최근 upsert)")

    // 동일 키 재저장 → 업데이트
    let d2updated = MonthlyDeposit(yearMonth: "2026-03", actualAmount: 900_000, plannedAmount: 1_500_000)
    storage.upsertDeposit(d2updated)
    let list2 = storage.loadDeposits()
    expect(list2.count, 2, "upsert는 중복 생성 안함")
    expect(list2.first(where: { $0.yearMonth == "2026-03" })?.actualAmount, Decimal(900_000), "동일 키 갱신")
}

do {
    storage.onboardingCompleted = false
    expect(storage.onboardingCompleted, false, "온보딩 기본 false")
    storage.onboardingCompleted = true
    expect(storage.onboardingCompleted, true, "온보딩 true 저장")
}

do {
    storage.recentMotivationTemplates = []
    storage.pushRecentMotivation("a")
    storage.pushRecentMotivation("b")
    storage.pushRecentMotivation("c")
    expect(storage.recentMotivationTemplates, ["c", "b", "a"], "최근 멘트 역순 stack")
    storage.pushRecentMotivation("b")
    expect(storage.recentMotivationTemplates, ["b", "c", "a"], "중복 제거 후 맨 앞")

    for i in 0..<30 { storage.pushRecentMotivation("msg\(i)", maxKept: 5) }
    expect(storage.recentMotivationTemplates.count, 5, "maxKept=5 잘라냄")
}

do {
    storage.monthlyIncomeForRatio = 3_000_000
    expect(storage.monthlyIncomeForRatio, Decimal(3_000_000), "monthlyIncome 저장")
    storage.monthlyIncomeForRatio = nil
    expect(storage.monthlyIncomeForRatio, nil, "monthlyIncome 삭제")
}

section("WidgetSnapshot.build")

do {
    let goal = SavingsGoal(
        targetAmount: 100_000_000, currentAmount: 50_000_000,
        monthlyDeposit: 1_000_000, paydayOfMonth: 25, annualReturnRate: 0
    )
    storage.saveGoal(goal)
    let cal = SavingsCalculator.koreanCalendar
    var comps = DateComponents(); comps.year = 2026; comps.month = 4; comps.day = 24
    let now = cal.date(from: comps)!

    if let snap = WidgetSnapshot.build(from: storage, now: now) {
        expect(snap.progress, 0.5, "progress 50%")
        expect(snap.monthsRemaining, 50, "남은 50개월 (50M / 1M)")
        expect(snap.isImpossible, false, "가능 상태")
        if !snap.motivationText.isEmpty {
            passed += 1
            print("  ✓ snapshot 멘트: \(snap.motivationText)")
        } else {
            failed += 1
            print("  ✗ snapshot 멘트 빈 문자열")
        }
    } else {
        failed += 1
        print("  ✗ snapshot build 실패")
    }
}

do {
    let goal = SavingsGoal(
        targetAmount: 100_000_000, currentAmount: 0,
        monthlyDeposit: 0, paydayOfMonth: 25, annualReturnRate: 0
    )
    storage.saveGoal(goal)
    let snap = WidgetSnapshot.build(from: storage)
    expect(snap?.isImpossible, true, "달성 불가 상태 flagging")
}

// cleanup
testDefaults.removePersistentDomain(forName: testSuite)

// ────────────────────────────────────────────────────────
// Summary
// ────────────────────────────────────────────────────────

print("\n════════════════════════════════════════")
print("  ✓ passed: \(passed)")
print("  ✗ failed: \(failed)")
print("════════════════════════════════════════")

if failed > 0 {
    exit(1)
}
