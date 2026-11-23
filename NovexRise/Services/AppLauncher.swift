import UIKit

/// Abre la app elegida cuando el usuario decide entrar.
/// Prueba cada dirección en orden (esquema de la app y, al final, su web).
@MainActor
enum AppLauncher {
    static func open(_ app: ControlledApp) {
        let urls = app.launchURLs
        Task { @MainActor in
            for url in urls {
                if await UIApplication.shared.open(url) { return }
            }
        }
    }
}
