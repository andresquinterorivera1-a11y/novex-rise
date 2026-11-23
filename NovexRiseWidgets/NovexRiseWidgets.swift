import ActivityKit
import SwiftUI
import WidgetKit

@main
struct NovexRiseWidgetsBundle: WidgetBundle {
    var body: some Widget {
        SessionLiveActivity()
    }
}

/// Cuenta regresiva de la sesión en la pantalla de bloqueo y en la Isla Dinámica.
struct SessionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SessionActivityAttributes.self) { context in
            LockScreenSessionView(context: context)
                .activityBackgroundTint(Color.black)
                .activitySystemActionForegroundColor(Color.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label(context.attributes.appName, systemImage: context.attributes.symbol)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    CountdownText(state: context.state)
                        .font(.title3.weight(.bold).monospacedDigit())
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 90, alignment: .trailing)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.extended ? "Extensión usada · sal con intención" : "No sigas el scroll, marca tu ritmo.")
                        .font(.caption)
                        .foregroundColor(Color(white: 0.6))
                }
            } compactLeading: {
                NovexMarkView()
                    .frame(width: 16, height: 16)
            } compactTrailing: {
                CountdownText(state: context.state)
                    .font(.caption.weight(.semibold).monospacedDigit())
                    .frame(width: 44)
            } minimal: {
                NovexMarkView()
                    .frame(width: 14, height: 14)
            }
            .keylineTint(Color.white)
        }
    }
}

private struct CountdownText: View {
    let state: SessionActivityAttributes.ContentState

    var body: some View {
        // startDate siempre es menor o igual que endDate (lo garantiza la app).
        Text(timerInterval: state.startDate...max(state.startDate, state.endDate), countsDown: true)
            .foregroundColor(.white)
    }
}

private struct LockScreenSessionView: View {
    let context: ActivityViewContext<SessionActivityAttributes>

    var body: some View {
        HStack(spacing: 14) {
            NovexMarkView()
                .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text("NOVEX RISE")
                    .font(.caption2.weight(.heavy))
                    .tracking(2)
                    .foregroundColor(Color(white: 0.6))
                Text("Tiempo en \(context.attributes.appName)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
            }

            Spacer()

            CountdownText(state: context.state)
                .font(.system(size: 30, weight: .bold).monospacedDigit())
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 110, alignment: .trailing)
        }
        .padding(16)
    }
}
