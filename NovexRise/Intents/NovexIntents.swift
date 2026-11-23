import AppIntents
import Foundation

// Acciones de NOVEX RISE para la app Atajos.
//
// iOS 26 o posterior — UNA sola automatización para todas las apps:
//   Cuando «TikTok», «Instagram», … se abra (Ejecutar inmediatamente) →
//     Pausa NOVEX RISE
//
//   La acción decide sola: si ya elegiste un tiempo, no hace nada y te deja
//   pasar; si no, trae NOVEX RISE al frente con la pausa consciente.
//
// iOS 18 o anterior — Atajos no permite que una acción decida si abre la app,
// así que se necesitan dos acciones y un «Si»:
//   1. ¿Puedo entrar?
//   2. Si [Resultado] es «pausa» → Abrir pausa consciente

extension ControlledApp: AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "App"

    static var caseDisplayRepresentations: [ControlledApp: DisplayRepresentation] = [
        .instagram: "Instagram",
        .tiktok: "TikTok",
        .youtube: "YouTube",
        .facebook: "Facebook",
        .x: "X",
        .snapchat: "Snapchat",
        .whatsapp: "WhatsApp",
        .reddit: "Reddit",
        .threads: "Threads",
        .pinterest: "Pinterest",
        .twitch: "Twitch",
        .netflix: "Netflix"
    ]
}

// MARK: - iOS 26 o posterior: una sola acción

@available(iOS 26.0, *)
struct NovexPauseIntent: AppIntent {
    static var title: LocalizedStringResource = "Pausa NOVEX RISE"
    static var description = IntentDescription(
        "Ponla en una automatización «Cuando se abra…». Si ya elegiste un tiempo, te deja pasar; si no, abre la pausa consciente."
    )

    /// Empieza en segundo plano y solo pasa al frente cuando toca la pausa.
    /// Así no se forma un bucle cuando NOVEX RISE te devuelve a la app.
    static var supportedModes: IntentModes = [.background, .foreground(.dynamic)]

    @Parameter(
        title: "App",
        description: "Opcional. Si lo dejas vacío, NOVEX RISE te pregunta a qué app ibas."
    )
    var app: ControlledApp?

    static var parameterSummary: some ParameterSummary {
        Summary("Pausa NOVEX RISE") {
            \.$app
        }
    }

    func perform() async throws -> some IntentResult {
        let target = app
        let allowed = await MainActor.run { NovexStore.shared.canEnter(target) }
        if allowed {
            // Ya elegiste un tiempo: no se muestra nada.
            return .result()
        }

        if systemContext.currentMode.canContinueInForeground {
            do {
                try await continueInForeground(alwaysConfirm: false)
            } catch {
                return .result()
            }
        }

        await MainActor.run {
            AppRouter.shared.presentPause(for: target, mode: .entry)
        }
        return .result()
    }
}

// MARK: - iOS 18 o anterior: dos acciones con «Si»

/// Devuelve «entrar» si hay una sesión activa, o «pausa» si toca la pausa consciente.
struct CheckAccessIntent: AppIntent {
    static var title: LocalizedStringResource = "¿Puedo entrar?"
    static var description = IntentDescription(
        "Para iOS 18 o anterior. Responde «entrar» si ya elegiste un tiempo en NOVEX RISE, o «pausa» si toca la pausa consciente."
    )
    static var openAppWhenRun: Bool = false

    @Parameter(title: "App", description: "Opcional.")
    var app: ControlledApp?

    static var parameterSummary: some ParameterSummary {
        Summary("¿Puedo entrar?") {
            \.$app
        }
    }

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let allowed = NovexStore.shared.canEnter(app)
        return .result(value: allowed ? "entrar" : "pausa")
    }
}

/// Abre NOVEX RISE directamente en la pantalla de pausa.
struct OpenPauseIntent: AppIntent {
    static var title: LocalizedStringResource = "Abrir pausa consciente"
    static var description = IntentDescription(
        "Para iOS 18 o anterior. Abre NOVEX RISE con la respiración guiada antes de entrar a la app."
    )
    static var openAppWhenRun: Bool = true

    @Parameter(title: "App", description: "Opcional.")
    var app: ControlledApp?

    static var parameterSummary: some ParameterSummary {
        Summary("Abrir pausa consciente") {
            \.$app
        }
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        AppRouter.shared.presentPause(for: app, mode: .entry)
        return .result()
    }
}
