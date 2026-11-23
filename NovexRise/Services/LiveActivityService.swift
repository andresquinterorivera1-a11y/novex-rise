import ActivityKit
import Foundation

/// Cuenta regresiva en la pantalla de bloqueo y la Isla Dinámica.
/// Si el usuario desactivó las Live Activities, la app sigue funcionando sin ellas.
enum LiveActivityService {
    static func start(session: ActiveSession) async {
        await endAll()
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = SessionActivityAttributes(appName: session.app.name, symbol: session.app.symbol)
        let state = contentState(for: session)
        do {
            if #available(iOS 16.2, *) {
                _ = try Activity.request(
                    attributes: attributes,
                    content: ActivityContent(state: state, staleDate: session.end),
                    pushType: nil
                )
            } else {
                _ = try Activity.request(attributes: attributes, contentState: state, pushType: nil)
            }
        } catch {
            print("NOVEX RISE · no se pudo iniciar la Live Activity: \(error)")
        }
    }

    static func update(session: ActiveSession) async {
        let state = contentState(for: session)
        for activity in Activity<SessionActivityAttributes>.activities {
            if #available(iOS 16.2, *) {
                await activity.update(ActivityContent(state: state, staleDate: session.end))
            } else {
                await activity.update(using: state)
            }
        }
    }

    static func endAll() async {
        for activity in Activity<SessionActivityAttributes>.activities {
            if #available(iOS 16.2, *) {
                await activity.end(nil, dismissalPolicy: .immediate)
            } else {
                await activity.end(dismissalPolicy: .immediate)
            }
        }
    }

    private static func contentState(for session: ActiveSession) -> SessionActivityAttributes.ContentState {
        SessionActivityAttributes.ContentState(
            startDate: session.start,
            endDate: max(session.start, session.end),
            extended: session.extensionUsed
        )
    }
}
