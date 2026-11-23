import SwiftUI

/// La función estrella: pausa consciente a pantalla completa.
/// Respiración → (¿Qué app?) → ¿De verdad quieres entrar? → ¿Cuánto tiempo? → ¿Para qué? → abre la app.
struct PauseFlowView: View {
    let request: PauseRequest

    @EnvironmentObject private var store: NovexStore
    @EnvironmentObject private var router: AppRouter

    @State private var step: Step
    /// Semilla de una sola vez desde `request.app`. Si es nil, se elige en el paso `.chooseApp`.
    @State private var app: ControlledApp?
    @State private var attemptNumber = 0
    @State private var quote = Quotes.random()
    @State private var goal: String?
    @State private var minutes: Int?
    @State private var isStarting = false
    @State private var isPrepared = false

    enum Step: Hashable {
        case breathing, chooseApp, question, duration, intention, declined, timeUp, exited
    }

    init(request: PauseRequest) {
        self.request = request
        // Semilla de una sola vez: cada PauseRequest crea una vista nueva (ver `.id(request.id)` en RootView).
        let first: Step
        switch request.mode {
        case .entry: first = .breathing
        case .timeUp: first = .timeUp
        case .exited: first = .exited
        }
        _step = State(initialValue: first)
        _app = State(initialValue: request.app)
    }

    var body: some View {
        ZStack {
            Palette.background.ignoresSafeArea()

            content
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .id(step)
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
        }
        .animation(.easeInOut(duration: 0.4), value: step)
        .interactiveDismissDisabled()
        .onAppear(perform: prepare)
    }

    @ViewBuilder
    private var content: some View {
        switch step {
        case .breathing:
            BreathingView(seconds: store.state.breathingSeconds) {
                step = app == nil ? .chooseApp : .question
            }
        case .chooseApp:
            AppChoiceStepView(apps: choosableApps, onSelect: choose)
        case .question:
            if let app {
                QuestionStepView(
                    app: app,
                    attemptNumber: attemptNumber,
                    goal: goal,
                    quote: quote,
                    onEnter: { step = .duration },
                    onDecline: decline
                )
            }
        case .duration:
            if let app {
                DurationStepView(
                    app: app,
                    onBack: { step = .question },
                    onContinue: { chosen in
                        minutes = chosen
                        step = .intention
                    }
                )
            }
        case .intention:
            IntentionStepView(isStarting: isStarting, onSelect: enter)
        case .declined:
            ResultStepView(title: "Subiste de nivel.", message: declinedMessage, quote: quote, onDone: close)
        case .timeUp:
            if let app {
                TimeUpStepView(app: app, canExtend: canExtend, onExit: exitOnTime, onExtend: extend)
            }
        case .exited:
            ResultStepView(
                title: "Saliste a tiempo.",
                message: "Así se marca el ritmo. Tu tiempo vuelve a ser tuyo.",
                quote: quote,
                onDone: close
            )
        }
    }

    // MARK: - Acciones

    private func prepare() {
        guard request.mode == .entry, !isPrepared else { return }
        isPrepared = true
        goal = store.state.goals.randomElement()
        if let app {
            attemptNumber = store.registerAttempt(for: app)
        }
    }

    private func choose(_ chosen: ControlledApp) {
        app = chosen
        attemptNumber = store.registerAttempt(for: chosen)
        step = .question
    }

    private func decline() {
        guard let app else { return }
        store.decline(app)
        step = .declined
    }

    private func enter(_ intention: Intention?) {
        guard let app, let minutes, !isStarting else { return }
        isStarting = true
        Task {
            await store.startSession(app: app, minutes: minutes, intention: intention)
            AppLauncher.open(app)
            router.closePause()
        }
    }

    private func exitOnTime() {
        store.finishSession(exitedOnTime: true)
        step = .exited
    }

    private func extend() {
        guard let app else { return }
        Task {
            if await store.extendSession() {
                AppLauncher.open(app)
                router.closePause()
            }
        }
    }

    private func close() {
        router.closePause()
    }

    /// Tus apps elegidas; si no elegiste ninguna, todas.
    private var choosableApps: [ControlledApp] {
        store.state.selectedApps.isEmpty ? ControlledApp.allCases : store.state.selectedApps
    }

    private var canExtend: Bool {
        guard let session = store.state.session else { return false }
        return session.app == app && !session.extensionUsed
    }

    private var declinedMessage: String {
        let count = store.count(.declined, in: NovexStore.todayInterval())
        let times = count == 1 ? "vez" : "veces"
        return "Hoy elegiste no entrar \(count) \(times). Cada «no» te acerca a tu meta."
    }
}
