import Foundation

struct DayBucket: Identifiable {
    let day: Date
    let attempts: Int
    let declines: Int

    var id: Date { day }
}

struct AppStats: Identifiable {
    let app: ControlledApp
    var attempts = 0
    var entered = 0
    var declined = 0
    var minutes = 0

    var id: String { app.rawValue }
}

struct IntentionCount: Identifiable {
    let intention: Intention
    let count: Int

    var id: String { intention.rawValue }
}

struct StatsSummary {
    var attempts = 0
    var entered = 0
    var declined = 0
    var exitedOnTime = 0
    var extensions = 0
    var minutesAllowed = 0
    var perApp: [AppStats] = []
    var intentions: [IntentionCount] = []
}

extension NovexStore {
    // MARK: Intervalos

    static func todayInterval(now: Date = Date()) -> DateInterval {
        lastDaysInterval(1, now: now)
    }

    /// Últimos 7 días, incluyendo hoy.
    static func weekInterval(now: Date = Date()) -> DateInterval {
        lastDaysInterval(7, now: now)
    }

    /// Los 7 días anteriores a `weekInterval`.
    static func previousWeekInterval(now: Date = Date()) -> DateInterval {
        lastDaysInterval(7, endingDaysAgo: 7, now: now)
    }

    static func lastDaysInterval(_ days: Int, endingDaysAgo offset: Int = 0, now: Date = Date()) -> DateInterval {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: now)
        let end = calendar.date(byAdding: .day, value: 1 - offset, to: todayStart)
            ?? todayStart.addingTimeInterval(TimeInterval((1 - offset) * 86_400))
        let start = calendar.date(byAdding: .day, value: -days, to: end)
            ?? end.addingTimeInterval(TimeInterval(-days * 86_400))
        return DateInterval(start: start, end: end)
    }

    // MARK: Consultas

    func count(_ kind: NovexEvent.Kind, app: ControlledApp? = nil, in interval: DateInterval) -> Int {
        state.events.filter { event in
            event.kind == kind
                && (app == nil || event.app == app)
                && event.date >= interval.start
                && event.date < interval.end
        }.count
    }

    func summary(in interval: DateInterval) -> StatsSummary {
        var summary = StatsSummary()
        var perApp: [ControlledApp: AppStats] = [:]
        var intentions: [Intention: Int] = [:]

        for event in state.events where event.date >= interval.start && event.date < interval.end {
            var appStats = perApp[event.app] ?? AppStats(app: event.app)
            switch event.kind {
            case .attempt:
                summary.attempts += 1
                appStats.attempts += 1
            case .entered:
                let minutes = event.minutes ?? 0
                summary.entered += 1
                summary.minutesAllowed += minutes
                appStats.entered += 1
                appStats.minutes += minutes
                if let intention = event.intention {
                    intentions[intention, default: 0] += 1
                }
            case .declined:
                summary.declined += 1
                appStats.declined += 1
            case .extended:
                let minutes = event.minutes ?? 0
                summary.extensions += 1
                summary.minutesAllowed += minutes
                appStats.minutes += minutes
            case .exitedOnTime:
                summary.exitedOnTime += 1
            }
            perApp[event.app] = appStats
        }

        summary.perApp = perApp.values.sorted { lhs, rhs in
            lhs.attempts == rhs.attempts ? lhs.app.name < rhs.app.name : lhs.attempts > rhs.attempts
        }
        summary.intentions = Intention.allCases.compactMap { intention in
            intentions[intention].map { IntentionCount(intention: intention, count: $0) }
        }
        return summary
    }

    func dailyBuckets(days: Int = 7, now: Date = Date()) -> [DayBucket] {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: now)
        return (0..<days).reversed().map { offset in
            let start = calendar.date(byAdding: .day, value: -offset, to: todayStart) ?? todayStart
            let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start.addingTimeInterval(86_400)
            let day = summary(in: DateInterval(start: start, end: end))
            return DayBucket(day: start, attempts: day.attempts, declines: day.declined)
        }
    }
}
