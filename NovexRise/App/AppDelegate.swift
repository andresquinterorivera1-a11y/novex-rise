import UIKit
import UserNotifications

final class AppDelegate: NSObject, UIApplicationDelegate {
    private let notificationDelegate = NotificationDelegate()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Debe asignarse antes de terminar el arranque para recibir
        // los botones de la notificación aunque la app estuviera cerrada.
        UNUserNotificationCenter.current().delegate = notificationDelegate
        NotificationService.registerCategories()
        return true
    }
}

/// Maneja los botones "Salgo, subo de nivel" y "2 minutos más".
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let request = response.notification.request
        let action = response.actionIdentifier
        let rawApp = request.content.userInfo[NotificationService.appKey] as? String
        let app = rawApp.flatMap(ControlledApp.init(rawValue:))
        let isEndNotification = request.identifier == NotificationService.endID

        Task { @MainActor in
            let store = NovexStore.shared
            let router = AppRouter.shared

            switch action {
            case NotificationService.actionExtend:
                await store.extendSession()
            case NotificationService.actionExit:
                store.finishSession(exitedOnTime: true)
                if let app { router.presentPause(for: app, mode: .exited) }
            case UNNotificationDefaultActionIdentifier:
                if isEndNotification, let app { router.presentPause(for: app, mode: .timeUp) }
            default:
                break
            }
            completionHandler()
        }
    }
}
