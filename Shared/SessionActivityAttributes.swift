import ActivityKit
import Foundation

/// Datos de la Live Activity que muestra la cuenta regresiva de una sesión.
/// Se comparte entre la app y la extensión de widgets.
struct SessionActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var startDate: Date
        var endDate: Date
        var extended: Bool
    }

    var appName: String
    var symbol: String
}
