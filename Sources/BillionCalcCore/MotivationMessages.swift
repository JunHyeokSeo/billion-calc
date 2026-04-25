import Foundation

public enum MotivationCategory: String, CaseIterable, Sendable {
    case payday
    case milestone25, milestone50, milestone75, milestone90, milestone100
    case everyday
    case whatIf
    case feedbackOver, feedbackOnPlan, feedbackUnder, feedbackZero
    case anniversary1Month, anniversary6Month, anniversary1Year
    case warningImpossible, warningHighRate, warningHighRatio
}

public struct MotivationMessage: Sendable, Hashable {
    public let template: String
    public let category: MotivationCategory
    public let widgetFriendly: Bool

    public init(_ template: String, _ category: MotivationCategory, widgetFriendly: Bool = false) {
        self.template = template
        self.category = category
        self.widgetFriendly = widgetFriendly
    }
}

public struct MotivationContext: Sendable {
    public var progress: Double
    public var daysRemaining: Int
    public var monthsRemaining: Int
    public var totalSaved: Decimal
    public var isPaydayToday: Bool
    public var monthsSinceStart: Int
    public var lastDepositDelta: Decimal?
    public var whatIfExtraAmount: Decimal?
    public var whatIfShortenedMonths: Int?
    public var annualReturnRate: Double
    public var savingToIncomeRatio: Double?
    public var isImpossible: Bool
    public var paydayCount: Int

    public init(
        progress: Double = 0,
        daysRemaining: Int = 0,
        monthsRemaining: Int = 0,
        totalSaved: Decimal = 0,
        isPaydayToday: Bool = false,
        monthsSinceStart: Int = 0,
        lastDepositDelta: Decimal? = nil,
        whatIfExtraAmount: Decimal? = nil,
        whatIfShortenedMonths: Int? = nil,
        annualReturnRate: Double = 0,
        savingToIncomeRatio: Double? = nil,
        isImpossible: Bool = false,
        paydayCount: Int = 0
    ) {
        self.progress = progress
        self.daysRemaining = daysRemaining
        self.monthsRemaining = monthsRemaining
        self.totalSaved = totalSaved
        self.isPaydayToday = isPaydayToday
        self.monthsSinceStart = monthsSinceStart
        self.lastDepositDelta = lastDepositDelta
        self.whatIfExtraAmount = whatIfExtraAmount
        self.whatIfShortenedMonths = whatIfShortenedMonths
        self.annualReturnRate = annualReturnRate
        self.savingToIncomeRatio = savingToIncomeRatio
        self.isImpossible = isImpossible
        self.paydayCount = paydayCount
    }
}

public enum MotivationLibrary {

    public static let all: [MotivationMessage] = [
        // ── 월급날 ──
        .init("💰 오늘 월급이 통장에 들어왔어요. 목표까지 {days}일 남았어요", .payday),
        .init("💵 이번 달 {amount}원 모으기 시작! {months}개월 남았어요", .payday),
        .init("📊 월급날. {percent}% 지점까지 {days}일 거리네요", .payday),
        .init("💳 월급이 들어왔으니 이번 달도 시작이에요", .payday),
        .init("⏰ 또 월급날이네요. 이렇게 {count}번 벌었어요", .payday),
        .init("📈 월급의 일부만 모으면 {months}개월 뒤에 목표예요", .payday),
        .init("💎 월급날의 설렘. 저번 달보다 더 가까워졌어요", .payday),
        .init("🎯 월급 통장 확인. 이제 {percent}%만 남았어요", .payday),
        .init("💰 월급일 하루도 이득. 목표일까지 한 걸음 더", .payday),
        .init("📍 지금까지 {total_amount}원 모았어요", .payday),

        // ── 마일스톤 25% ──
        .init("🔥 벌써 4분의 1이네요. 하나의 산을 올랐어요", .milestone25, widgetFriendly: true),
        .init("📍 1억의 일부, {amount}원을 모았어요. 확실한 시작이에요", .milestone25),
        .init("✅ 25% 지점. 이제 습관이 됐잖아요", .milestone25, widgetFriendly: true),
        .init("📊 4등분 중 1개 완성. 남은 것도 이 속도면 돼요", .milestone25),
        .init("💪 분기마다 이렇게 모으면 된다는 걸 증명했어요", .milestone25),

        // ── 마일스톤 50% ──
        .init("🎉 반반입니다. 이제 정말 보이네요", .milestone50, widgetFriendly: true),
        .init("📈 중간 지점 통과. 여기까지 온 당신을 보세요", .milestone50, widgetFriendly: true),
        .init("⏳ 남은 것도 딱 {amount}원. 흉내 내는 게 아니네요", .milestone50),
        .init("💯 50%는 운이 아니라 습관이었어요", .milestone50, widgetFriendly: true),
        .init("🏔️ 산의 중턱. 내려갈 일만 남았어요", .milestone50),

        // ── 마일스톤 75% ──
        .init("🔥 드디어 3/4. 끝이 보이는 느낌이 다르네요", .milestone75, widgetFriendly: true),
        .init("📍 {months}개월 남았어요. 짧아졌죠?", .milestone75),
        .init("✨ 75%는 더 이상 꿈이 아니에요", .milestone75, widgetFriendly: true),
        .init("💎 마지막 25%. 당신이 이미 증명했으니까요", .milestone75, widgetFriendly: true),
        .init("🚀 거의 다 왔어요. 이 속도 유지하면 끝이에요", .milestone75),

        // ── 마일스톤 90% ──
        .init("🎯 90%. 이제 진짜 가까워졌어요", .milestone90, widgetFriendly: true),
        .init("🏁 도착선이 선명해요. 남은 {amount}원만 있으면 돼요", .milestone90),
        .init("💫 10%만 남았다니. 지금까지의 노력 생각하셨어요?", .milestone90, widgetFriendly: true),
        .init("📊 마지막 스퍼트. {months}개월이면 끝이에요", .milestone90),
        .init("🌟 90%를 모은 당신. 이미 충분하지 않나요?", .milestone90, widgetFriendly: true),

        // ── 100% 달성 ──
        .init("🎉 1억 달성! 이제 당신이 한 말이 아니라 현실이에요", .milestone100, widgetFriendly: true),
        .init("🏆 목표 달성했어요. {months}개월 만에요", .milestone100),
        .init("✨ 축하합니다. 그냥 축하해요, 정말로", .milestone100, widgetFriendly: true),
        .init("🎊 100% 도달. 이제 뭐할 거예요?", .milestone100, widgetFriendly: true),
        .init("🚀 목표 달성. 이 기분 자주 맛봤으면 좋겠어요", .milestone100, widgetFriendly: true),

        // ── 평일 ──
        .init("💬 이 정도면 괜찮은 페이스예요", .everyday, widgetFriendly: true),
        .init("📊 오늘도 목표에 가까워졌어요", .everyday, widgetFriendly: true),
        .init("💳 이 습관이 통장보다 더 중요해요", .everyday),
        .init("⏰ 다음 월급일까지 조금만", .everyday, widgetFriendly: true),
        .init("🎯 {percent}% 도달. 당신의 속도면 가능해요", .everyday, widgetFriendly: true),
        .init("💰 한 달 지나면 또 {amount}원이 쌓여요", .everyday),
        .init("📈 지금까지의 평균 속도면 {months}개월이에요", .everyday, widgetFriendly: true),
        .init("🔥 매달 모으는 습관. 기적이 되는 순간이 있어요", .everyday),
        .init("📍 작은 것들이 모이면 큰 것이 돼요", .everyday, widgetFriendly: true),
        .init("💎 통장을 봤을 때의 그 기분, 오래 가길 바라요", .everyday),
        .init("🌟 지금 당신의 페이스라면 가능해요", .everyday, widgetFriendly: true),
        .init("✅ 계획대로라면 {months}개월 후가 목표예요", .everyday),
        .init("📊 매달 조금씩 채워지고 있어요", .everyday, widgetFriendly: true),
        .init("💫 꾸준함의 힘. 오늘도 보이시나요?", .everyday),
        .init("🎊 한 달에 한 번의 기쁨. 그게 쌓이는 거예요", .everyday),

        // ── What-if ──
        .init("📈 월 {extra_amount}원 더 모으면 {shortened_months}개월 단축돼요", .whatIf),
        .init("🚀 {extra_amount}원/월 추가하면 빨라져요", .whatIf),
        .init("💰 월 {extra_amount}원 늘려보세요. 이렇게 달라져요", .whatIf),
        .init("🎯 {shortened_months}개월이 줄어들 거예요", .whatIf),
        .init("⏳ {extra_amount}원/월이면 더 빨리 끝낼 수 있어요", .whatIf),
        .init("📊 {extra_amount}원 추가하면 이렇게 돼요", .whatIf),
        .init("🔥 이 정도 수준이면 현실적이에요", .whatIf),
        .init("💎 {shortened_months}개월을 버는 거네요. 어떨까요?", .whatIf),

        // ── 피드백: 계획 초과 ──
        .init("🎉 계획보다 {extra_amount}원 더 모으셨네요", .feedbackOver),
        .init("💪 계획 초과. 목표일이 앞당겨졌어요", .feedbackOver),
        .init("🔥 이번 달은 여유가 있으셨나봐요", .feedbackOver),
        .init("⭐ 계획 + α. 가장 설레는 달이에요", .feedbackOver),

        // ── 피드백: 계획대로 ──
        .init("✅ 계획 달성. 이게 가장 어려운 거 아시나요?", .feedbackOnPlan),
        .init("📊 딱 맞췄어요. 이것도 실력이에요", .feedbackOnPlan),
        .init("💯 정확히 계획대로. 신뢰할 수 있는 페이스네요", .feedbackOnPlan),
        .init("🎯 예정대로 진행 중. 좋은 신호예요", .feedbackOnPlan),

        // ── 피드백: 계획 미달 ──
        .init("💭 이번 달은 힘들었나봐요. 괜찮아요, 이런 달도 있어요", .feedbackUnder),
        .init("📉 조금 모자랐네요. 다음 달 기회예요", .feedbackUnder),
        .init("🌙 모자란 달도 있어요. 멈추지 마세요", .feedbackUnder),
        .init("💙 힘든 달이었겠죠. 모아주셔서 고마워요", .feedbackUnder),

        // ── 피드백: 0원 (쉬어가기) ──
        .init("🌟 이번 달은 쉬어가기로 정했군요. 그것도 계획이에요", .feedbackZero),
        .init("💭 쉬면서도 목표는 계속 가고 있어요", .feedbackZero),
        .init("🌙 몸과 마음도 중요하니까요. 다시 돌아오세요", .feedbackZero),
        .init("✨ 멈춘 게 아니라 숨 쉬는 거예요", .feedbackZero),

        // ── 기념일 ──
        .init("🎊 이미 1개월이 지났어요! 처음이 가장 어려워요", .anniversary1Month),
        .init("📍 1개월간 수고 많으셨어요. 이제 시작이에요", .anniversary1Month),
        .init("💫 한 달 동안 매일 확인한 이유, 느껴지시나요?", .anniversary1Month),

        .init("🔥 벌써 6개월이에요. 반년을 버티셨어요", .anniversary6Month),
        .init("📈 6개월 전의 당신과 지금 당신은 달라요", .anniversary6Month),
        .init("💎 반년을 함께했네요. 이제 본능이에요", .anniversary6Month),

        .init("🏆 1년이에요. 축하해요, 정말로요", .anniversary1Year),
        .init("🌟 365일을 버티신 당신. 이제 뭐든 가능해요", .anniversary1Year),
        .init("🚀 1년 전 다짐이 현실이 되는 순간", .anniversary1Year),

        // ── 경고 ──
        .init("⚠️ 매달 저축이 없으면 목표에 닿을 수 없어요", .warningImpossible),
        .init("⚠️ {rate}%는 정말 높은 수익률이에요. 다시 한번 볼까요?", .warningHighRate),
        .init("⚠️ 월급의 {percent}%를 저축하시려네요. 일상도 챙기셔야 해요", .warningHighRatio)
    ]

    public static func messages(for category: MotivationCategory, widgetOnly: Bool = false) -> [MotivationMessage] {
        all.filter { $0.category == category && (!widgetOnly || $0.widgetFriendly) }
    }

    public static func render(_ template: String, substitutions: [String: String]) -> String {
        var out = template
        for (k, v) in substitutions {
            out = out.replacingOccurrences(of: "{\(k)}", with: v)
        }
        return out
    }

    public static func selectCategory(_ ctx: MotivationContext) -> MotivationCategory {
        if ctx.isImpossible { return .warningImpossible }
        if ctx.annualReturnRate > 15 { return .warningHighRate }
        if let ratio = ctx.savingToIncomeRatio, ratio > 0.5 { return .warningHighRatio }

        if ctx.progress >= 1.0 { return .milestone100 }

        if ctx.isPaydayToday {
            if let delta = ctx.lastDepositDelta {
                if delta > 0 { return .feedbackOver }
                if delta == 0 { return .feedbackOnPlan }
                return .feedbackUnder
            }
            return .payday
        }

        if ctx.progress >= 0.9 { return .milestone90 }
        if ctx.progress >= 0.75 { return .milestone75 }
        if ctx.progress >= 0.5 { return .milestone50 }
        if ctx.progress >= 0.25 { return .milestone25 }

        if ctx.monthsSinceStart >= 12 && ctx.monthsSinceStart < 13 { return .anniversary1Year }
        if ctx.monthsSinceStart >= 6 && ctx.monthsSinceStart < 7 { return .anniversary6Month }
        if ctx.monthsSinceStart >= 1 && ctx.monthsSinceStart < 2 { return .anniversary1Month }

        if ctx.whatIfShortenedMonths != nil { return .whatIf }

        return .everyday
    }

    public static func substitutions(_ ctx: MotivationContext) -> [String: String] {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.groupingSeparator = ","

        func money(_ d: Decimal) -> String {
            nf.string(from: d as NSDecimalNumber) ?? "\(d)"
        }

        var subs: [String: String] = [
            "days": "\(ctx.daysRemaining)",
            "months": "\(ctx.monthsRemaining)",
            "percent": "\(Int((ctx.progress * 100).rounded()))",
            "count": "\(max(0, ctx.paydayCount))",
            "rate": String(format: "%.1f", ctx.annualReturnRate),
            "amount": money(ctx.totalSaved),
            "total_amount": money(ctx.totalSaved)
        ]
        if let extra = ctx.whatIfExtraAmount {
            subs["extra_amount"] = money(extra)
        } else {
            subs["extra_amount"] = "0"
        }
        if let shortened = ctx.whatIfShortenedMonths {
            subs["shortened_months"] = "\(shortened)"
        } else {
            subs["shortened_months"] = "0"
        }
        if let delta = ctx.lastDepositDelta, delta < 0 {
            subs["less_amount"] = money(-delta)
        } else {
            subs["less_amount"] = "0"
        }
        return subs
    }

    public static func pick<G: RandomNumberGenerator>(
        context ctx: MotivationContext,
        excluding recentTemplates: Set<String> = [],
        widgetOnly: Bool = false,
        using rng: inout G
    ) -> String {
        let category = selectCategory(ctx)
        var candidates = messages(for: category, widgetOnly: widgetOnly)
            .filter { !recentTemplates.contains($0.template) }
        if candidates.isEmpty {
            candidates = messages(for: category, widgetOnly: widgetOnly)
        }
        if candidates.isEmpty {
            candidates = messages(for: .everyday, widgetOnly: widgetOnly)
        }
        let chosen = candidates.randomElement(using: &rng) ?? candidates.first!
        return render(chosen.template, substitutions: substitutions(ctx))
    }

    public static func pick(context ctx: MotivationContext, excluding recentTemplates: Set<String> = [], widgetOnly: Bool = false) -> String {
        var rng = SystemRandomNumberGenerator()
        return pick(context: ctx, excluding: recentTemplates, widgetOnly: widgetOnly, using: &rng)
    }
}
