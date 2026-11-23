import SwiftUI

/// La función estrella: pausa consciente a pantalla completa.
/// Respiración → ¿De verdad quieres entrar? → ¿Cuánto tiempo? → ¿Para qué? → abre la app.
struct PauseFlowView: View {
    let request: PauseRequest

    @EnvironmentObject private var store: NovexStore
    @EnvironmentObject private var router: AppRouter

    @State private var step: Step
    @State private var attemptNumber = 0
    @State private var quote = Quotes.random()
    @State private var goal: String?
    @State private var minutes: Int?
    @State private var isStarting = false

    enum Step: Hashable {
        case breathing, question, duration, intention, declined, timeUp, exited
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
                step = .question
            }
        case .question:
            QuestionStepView(
                app: request.app,
                attemptNumber: attemptNumber,
                goal: goal,
                quote: quote,
                onEnter: { step = .duration },
                onDecline: decline
            )
        case .duration:
            DurationStepView(
                app: request.app,
                onBack: { step = .question },
                onContinue: { chosen in
                    minutes = chosen
                    step = .intention
                }
            )
        case .intention:
            IntentionStepView(isStarting: isStarting, onSelect: enter)
        case .declined:
            ResultStepView(title: "Subiste de nivel.", message: declinedMessage, quote: quote, onDone: close)
        case .timeUp:
            TimeUpStepView(app: request.app, canExtend: canExtend, onExit: exitOnTime, onExtend: extend)
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
        guard request.mode == .entry, attemptNumber == 0 else { return }
        attemptNumber = store.registerAttempt(for: request.app)
        goal = store.state.goals.randomElement()
    }

    private func decline() {
        store.decline(request.app)
        step = .declined
    }

    private func enter(_ intention: Intention?) {
        guard let minutes, !isStarting else { return }
        isStarting = true
        Task {
            await store.startSession(app: request.app, minutes: minutes, intention: intention)
            AppLauncher.open(request.app)
            router.closePause()
        }
    }

    private func exitOnTime() {
        store.finishSession(exitedOnTime: true)
        step = .exited
    }

    private func extend() {
        Task {
            if await store.extendSession() {
                AppLauncher.open(request.app)
                router.closePause()
            }
        }
    }

    private func close() {
        router.closePause()
    }

    private var canExtend: Bool {
        guard let session = store.state.session else { return false }
        return session.app == request.app && !session.extensionUsed
    }

    private var declinedMessage: String {
        let count = store.count(.declined, in: NovexStore.todayInterval())
        let times = count == 1 ? "vez" : "veces"
        return "Hoy elegiste no entrar \(count) \(times). Cada «no» te acerca a tu meta."
    }
}
