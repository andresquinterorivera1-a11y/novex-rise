import Charts
import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var store: NovexStore
    @State private var range: StatsRange = .today

    enum StatsRange: String, CaseIterable, Identifiable {
        case today = "Hoy"
        case week = "7 días"

        var id: String { rawValue }
    }

    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    var body: some View {
        let interval = range == .today ? NovexStore.todayInterval() : NovexStore.weekInterval()
        let summary = store.summary(in: interval)

        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Estadísticas")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .padding(.top, 8)

                Picker("Periodo", selection: $range) {
                    ForEach(StatsRange.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)

                LazyVGrid(columns: columns, spacing: 10) {
                    StatTile(value: "\(summary.attempts)", label: "Intentos de abrir")
                    StatTile(value: "\(summary.declined)", label: "«No, hoy subo de nivel»")
                    StatTile(value: "\(summary.entered)", label: "Veces que entraste")
                    StatTile(value: "\(summary.minutesAllowed)", label: "Minutos que elegiste")
                    StatTile(value: "\(summary.exitedOnTime)", label: "Saliste a tiempo")
                    StatTile(value: "\(summary.extensions)", label: "Extensiones de 2 min")
                }

                VStack(alignment: .leading, spacing: 10) {
                    SectionTitle(text: "Últimos 7 días")
                    WeeklyChart(buckets: store.dailyBuckets(days: 7))
                        .novexCard()
                }

                WeekComparisonCard(
                    current: store.summary(in: NovexStore.weekInterval()),
                    previous: store.summary(in: NovexStore.previousWeekInterval())
                )

                if !summary.perApp.isEmpty {
                    PerAppCard(stats: summary.perApp)
                }

                if !summary.intentions.isEmpty {
                    IntentionsCard(intentions: summary.intentions)
                }

                Text("Todo se guarda solo en tu iPhone. NOVEX RISE no recolecta datos personales.")
                    .font(.footnote)
                    .foregroundColor(Palette.tertiary)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            }
            .padding(20)
        }
        .background(Palette.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct WeeklyChart: View {
    let buckets: [DayBucket]

    var body: some View {
        Chart {
            ForEach(buckets) { bucket in
                BarMark(
                    x: .value("Día", bucket.day, unit: .day),
                    y: .value("Veces", bucket.attempts)
                )
                .foregroundStyle(by: .value("Tipo", "Intentos"))
                .position(by: .value("Tipo", "Intentos"))

                BarMark(
                    x: .value("Día", bucket.day, unit: .day),
                    y: .value("Veces", bucket.declines)
                )
                .foregroundStyle(by: .value("Tipo", "Subiste de nivel"))
                .position(by: .value("Tipo", "Subiste de nivel"))
            }
        }
        .chartForegroundStyleScale([
            "Intentos": Color(white: 0.38),
            "Subiste de nivel": Color.white
        ])
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { _ in
                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
            }
        }
        .chartLegend(position: .bottom, alignment: .leading)
        .frame(height: 210)
        .accessibilityLabel("Intentos y veces que subiste de nivel en los últimos 7 días")
    }
}

private struct WeekComparisonCard: View {
    let current: StatsSummary
    let previous: StatsSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionTitle(text: "Contra la semana anterior")
            VStack(alignment: .leading, spacing: 8) {
                Text(attemptsLine)
                    .font(.headline)
                    .foregroundColor(.white)
                Text("Esta semana: \(current.attempts) intentos · \(current.declined) veces subiste de nivel")
                    .font(.footnote)
                    .foregroundColor(Palette.secondary)
                Text("Semana anterior: \(previous.attempts) intentos · \(previous.declined) veces subiste de nivel")
                    .font(.footnote)
                    .foregroundColor(Palette.tertiary)
            }
            .novexCard()
        }
    }

    private var attemptsLine: String {
        guard previous.attempts > 0 else {
            return current.attempts == 0 ? "Aún no hay datos para comparar." : "Tu primera semana con NOVEX RISE."
        }
        let change = Double(current.attempts - previous.attempts) / Double(previous.attempts) * 100
        let percent = Int(abs(change).rounded())
        if percent == 0 { return "Mismo número de intentos que la semana pasada." }
        return change < 0
            ? "\(percent) % menos intentos que la semana pasada. Vas subiendo."
            : "\(percent) % más intentos que la semana pasada. Hoy puedes cambiarlo."
    }
}

private struct PerAppCard: View {
    let stats: [AppStats]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionTitle(text: "Por app")
            VStack(spacing: 0) {
                ForEach(stats) { item in
                    HStack(spacing: 12) {
                        AppBadge(app: item.app, size: 34)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.app.name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.white)
                            Text("\(item.attempts) intentos · \(item.declined) «no» · \(item.minutes) min")
                                .font(.caption)
                                .foregroundColor(Palette.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .accessibilityElement(children: .combine)
                    if item.id != stats.last?.id {
                        Divider().overlay(Palette.stroke)
                    }
                }
            }
            .novexCard(padding: 14)
        }
    }
}

private struct IntentionsCard: View {
    let intentions: [IntentionCount]

    var body: some View {
        let total = max(1, intentions.reduce(0) { $0 + $1.count })

        VStack(alignment: .leading, spacing: 10) {
            SectionTitle(text: "¿Para qué entraste?")
            VStack(alignment: .leading, spacing: 14) {
                ForEach(intentions) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Label(item.intention.label, systemImage: item.intention.symbol)
                                .font(.subheadline)
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(item.count)")
                                .font(.subheadline.monospacedDigit().weight(.bold))
                                .foregroundColor(.white)
                        }
                        GeometryReader { proxy in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Palette.raised)
                                Capsule()
                                    .fill(Color.white)
                                    .frame(width: proxy.size.width * CGFloat(item.count) / CGFloat(total))
                            }
                        }
                        .frame(height: 6)
                        .accessibilityHidden(true)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
            .novexCard()
        }
    }
}
