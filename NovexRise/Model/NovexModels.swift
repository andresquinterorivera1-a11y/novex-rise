import Foundation

/// "¿Para qué vas a entrar?" — se guarda para las estadísticas.
enum Intention: String, Codable, CaseIterable, Identifiable {
    case messages, specific, boredom

    var id: String { rawValue }

    var label: String {
        switch self {
        case .messages: return "Responder mensajes"
        case .specific: return "Ver algo específico"
        case .boredom: return "Solo por aburrimiento"
        }
    }

    var symbol: String {
        switch self {
        case .messages: return "bubble.left"
        case .specific: return "scope"
        case .boredom: return "zzz"
        }
    }
}

/// Cada cosa que pasa en una pausa queda registrada aquí (solo en el iPhone).
struct NovexEvent: Codable, Identifiable, Hashable {
    enum Kind: String, Codable {
        case attempt       // Se mostró la pausa (intento de abrir la app)
        case entered       // Eligió entrar con un tiempo
        case declined      // "No, hoy subo de nivel"
        case extended      // Pidió 2 minutos más
        case exitedOnTime  // Salió cuando se acabó el tiempo
    }

    let id: UUID
    let date: Date
    let app: ControlledApp
    let kind: Kind
    var minutes: Int?
    var intention: Intention?

    init(app: ControlledApp, kind: Kind, minutes: Int? = nil, intention: Intention? = nil, date: Date = Date()) {
        self.id = UUID()
        self.date = date
        self.app = app
        self.kind = kind
        self.minutes = minutes
        self.intention = intention
    }
}

/// Permiso temporal para usar una app.
struct ActiveSession: Codable, Equatable {
    var app: ControlledApp
    var start: Date
    var end: Date
    var extensionUsed: Bool

    func isActive(at date: Date = Date()) -> Bool { end > date }
}

/// Todo lo que la app guarda. Se decodifica de forma tolerante para que
/// futuras versiones puedan añadir campos sin borrar los datos del usuario.
struct PersistedState: Codable {
    var onboardingDone = false
    var goals: [String] = []
    var selectedApps: [ControlledApp] = [.instagram, .tiktok, .youtube]
    var breathingSeconds = 6
    var events: [NovexEvent] = []
    var session: ActiveSession?

    init() {}

    private enum CodingKeys: String, CodingKey {
        case onboardingDone, goals, selectedApps, breathingSeconds, events, session
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        onboardingDone = try container.decodeIfPresent(Bool.self, forKey: .onboardingDone) ?? false
        goals = try container.decodeIfPresent([String].self, forKey: .goals) ?? []
        selectedApps = try container.decodeIfPresent([ControlledApp].self, forKey: .selectedApps) ?? [.instagram, .tiktok, .youtube]
        breathingSeconds = try container.decodeIfPresent(Int.self, forKey: .breathingSeconds) ?? 6
        events = try container.decodeIfPresent([NovexEvent].self, forKey: .events) ?? []
        session = try container.decodeIfPresent(ActiveSession.self, forKey: .session)
    }
}
