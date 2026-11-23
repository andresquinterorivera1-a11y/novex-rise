import Foundation
import UserNotifications

/// Avisos locales: 1 minuto antes y al terminar la sesión. Nada sale del iPhone.
enum NotificationService {
    static let warningID = "novex.session.warning"
    static let endID = "novex.session.end"
    static let appKey = "app"

    static let categoryEnd = "NOVEX_SESSION_END"
    static let categoryEndNoExtension = "NOVEX_SESSION_END_NO_EXTENSION"
    static let actionExtend = "NOVEX_EXTEND"
    static let actionExit = "NOVEX_EXIT"

    static func registerCategories() {
        let exit = UNNotificationAction(identifier: actionExit, title: "Salgo, subo de nivel", options: [.foreground])
        let extend = UNNotificationAction(identifier: actionExtend, title: "2 minutos más", options: [])
        let withExtension = UNNotificationCategory(identifier: categoryEnd, actions: [exit, extend], intentIdentifiers: [], options: [])
        let withoutExtension = UNNotificationCategory(identifier: categoryEndNoExtension, actions: [exit], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([withExtension, withoutExtension])
    }

    @discardableResult
    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func scheduleReminders(for session: ActiveSession) {
        cancelSessionReminders()
        let center = UNUserNotificationCenter.current()
        let remaining = session.end.timeIntervalSinceNow
        let appName = session.app.name

        if remaining > 65 {
            let warning = UNMutableNotificationContent()
            warning.title = "Te queda 1 minuto"
            warning.body = "Cierra \(appName) con intención. Tú marcas el ritmo."
            warning.sound = .default
            warning.userInfo = [appKey: session.app.rawValue]
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: remaining - 60, repeats: false)
            center.add(UNNotificationRequest(identifier: warningID, content: warning, trigger: trigger))
        }

        if remaining > 1 {
            let end = UNMutableNotificationContent()
            end.title = "Se acabó tu tiempo en \(appName)"
            end.body = session.extensionUsed
                ? "Ya usaste tu extensión. Sal ahora y sube de nivel."
                : "¿Sales o necesitas 2 minutos más?"
            end.sound = .default
            end.categoryIdentifier = session.extensionUsed ? categoryEndNoExtension : categoryEnd
            end.userInfo = [appKey: session.app.rawValue]
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: remaining, repeats: false)
            center.add(UNNotificationRequest(identifier: endID, content: end, trigger: trigger))
        }
    }

    static func cancelSessionReminders() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [warningID, endID])
        center.removeDeliveredNotifications(withIdentifiers: [warningID, endID])
    }
}
