import Combine
import Foundation

/// Fuente única de verdad de NOVEX RISE. Guarda todo en UserDefaults, solo en el iPhone.
/// Se usa siempre desde el hilo principal (vistas, intents marcados @MainActor y
/// el delegado de notificaciones, que salta al hilo principal).
final class NovexStore: ObservableObject {
    static let shared = NovexStore()

    static let maxGoals = 5
    static let extensionMinutes = 2
    private static let retentionDays = 90

    @Published private(set) var state: PersistedState {
        didSet { save() }
    }

    private let defaults: UserDefaults
    private let storageKey = "novex.rise.state.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(PersistedState.self, from: data) {
            state = decoded
        } else {
            state = PersistedState()
        }
        pruneOldEvents()
    }

    // MARK: - Configuración

    func completeOnboarding() {
        state.onboardingDone = true
    }

    func addGoal(_ text: String) {
        let goal = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !goal.isEmpty,
              state.goals.count < Self.maxGoals,
              !state.goals.contains(where: { $0.caseInsensitiveCompare(goal) == .orderedSame })
        else { return }
        state.goals.append(goal)
    }

    func removeGoal(_ goal: String) {
        state.goals.removeAll { $0 == goal }
    }

    func removeGoals(at offsets: IndexSet) {
        state.goals = state.goals.enumerated()
            .filter { !offsets.contains($0.offset) }
            .map(\.element)
    }

    func isSelected(_ app: ControlledApp) -> Bool {
        state.selectedApps.contains(app)
    }

    func setSelected(_ app: ControlledApp, _ selected: Bool) {
        if selected {
            guard !state.selectedApps.contains(app) else { return }
            state.selectedApps.append(app)
        } else {
            state.selectedApps.removeAll { $0 == app }
        }
    }

    func setBreathingSeconds(_ seconds: Int) {
        state.breathingSeconds = min(10, max(5, seconds))
    }

    // MARK: - Pausa consciente

    /// ¿Hay un permiso activo? Lo consulta la automatización de Atajos.
    /// Sin app concreta (una sola automatización para todas las apps),
    /// basta con que haya una sesión activa.
    func canEnter(_ app: ControlledApp?) -> Bool {
        guard let session = state.session, session.isActive() else { return false }
        guard let app else { return true }
        return session.app == app
    }

    /// Registra un intento de apertura y devuelve cuántos van hoy con esa app.
    @discardableResult
    func registerAttempt(for app: ControlledApp) -> Int {
        state.events.append(NovexEvent(app: app, kind: .attempt))
        return count(.attempt, app: app, in: Self.todayInterval())
    }

    func decline(_ app: ControlledApp) {
        state.events.append(NovexEvent(app: app, kind: .declined))
    }

    /// Empieza una sesión con tiempo. Es async porque la Live Activity
    /// debe pedirse mientras NOVEX RISE sigue en primer plano.
    @MainActor
    func startSession(app: ControlledApp, minutes: Int, intention: Intention?) async {
        let now = Date()
        let session = ActiveSession(
            app: app,
            start: now,
            end: now.addingTimeInterval(TimeInterval(minutes * 60)),
            extensionUsed: false
        )
        state.events.append(NovexEvent(app: app, kind: .entered, minutes: minutes, intention: intention))
        state.session = session
        NotificationService.scheduleReminders(for: session)
        await LiveActivityService.start(session: session)
    }

    var canExtend: Bool {
        guard let session = state.session else { return false }
        return !session.extensionUsed
    }

    /// "2 minutos más" — solo una vez por sesión.
    @MainActor
    @discardableResult
    func extendSession() async -> Bool {
        guard var session = state.session, !session.extensionUsed else { return false }
        session.end = max(session.end, Date()).addingTimeInterval(TimeInterval(Self.extensionMinutes * 60))
        session.extensionUsed = true
        state.session = session
        state.events.append(NovexEvent(app: session.app, kind: .extended, minutes: Self.extensionMinutes))
        NotificationService.scheduleReminders(for: session)
        await LiveActivityService.update(session: session)
        return true
    }

    func finishSession(exitedOnTime: Bool) {
        if exitedOnTime, let session = state.session {
            state.events.append(NovexEvent(app: session.app, kind: .exitedOnTime))
        }
        state.session = nil
        NotificationService.cancelSessionReminders()
        Task { await LiveActivityService.endAll() }
    }

    /// Se llama cada vez que la app vuelve a primer plano.
    func refreshSession() {
        guard let session = state.session else {
            Task { await LiveActivityService.endAll() }
            return
        }
        guard !session.isActive() else { return }
        Task { await LiveActivityService.endAll() }
        // Se conserva 10 minutos tras terminar para poder pedir la extensión desde la notificación.
        if session.end.addingTimeInterval(600) < Date() {
            state.session = nil
        }
    }

    // MARK: - Persistencia

    private func save() {
        guard let data = try? JSONEncoder().encode(state) else { return }
        defaults.set(data, forKey: storageKey)
    }

    private func pruneOldEvents() {
        guard let limit = Calendar.current.date(byAdding: .day, value: -Self.retentionDays, to: Date()) else { return }
        if state.events.contains(where: { $0.date < limit }) {
            state.events.removeAll { $0.date < limit }
        }
    }
}
