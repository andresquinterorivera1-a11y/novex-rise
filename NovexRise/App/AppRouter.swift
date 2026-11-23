import Combine
import Foundation

/// Una pausa que hay que mostrar a pantalla completa.
struct PauseRequest: Identifiable, Equatable {
    enum Mode: Equatable {
        case entry    // Se intentó abrir la app
        case timeUp   // Se acabó el tiempo
        case exited   // Salió a tiempo desde la notificación
    }

    let id = UUID()
    /// `nil` cuando una sola automatización cubre varias apps:
    /// la pausa pregunta a cuál ibas.
    let app: ControlledApp?
    let mode: Mode
}

/// Decide qué pantalla se muestra cuando la app se abre desde Atajos,
/// desde una notificación o desde un enlace novexrise://
final class AppRouter: ObservableObject {
    static let shared = AppRouter()

    @Published var pause: PauseRequest?

    func presentPause(for app: ControlledApp?, mode: PauseRequest.Mode = .entry) {
        pause = PauseRequest(app: app, mode: mode)
    }

    func closePause() {
        pause = nil
    }

    /// novexrise://pausa  ·  novexrise://pausa?app=instagram  ·  novexrise://tiempo?app=instagram
    func handle(url: URL) {
        guard url.scheme == "novexrise" else { return }
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let value = components?.queryItems?.first(where: { $0.name == "app" })?.value
        let app = value.flatMap { ControlledApp(rawValue: $0.lowercased()) }

        switch url.host {
        case "tiempo":
            if let app { presentPause(for: app, mode: .timeUp) }
        default:
            presentPause(for: app, mode: .entry)
        }
    }
}
