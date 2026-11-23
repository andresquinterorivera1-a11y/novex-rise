import AppIntents

// Acciones de NOVEX RISE para la app Atajos.
//
// Automatización recomendada (una por cada app):
//   Cuando «Instagram» se abra →
//     1. ¿Puedo entrar a Instagram?            (NOVEX RISE)
//     2. Si [Resultado] es «pausa»
//          Abrir pausa consciente para Instagram (NOVEX RISE)
//
// Así, cuando ya elegiste un tiempo, Atajos no vuelve a mostrar la pausa
// y no se forma un bucle al regresar a la app.

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

/// Devuelve «entrar» si hay una sesión activa para la app, o «pausa» si toca la pausa consciente.
struct CheckAccessIntent: AppIntent {
    static var title: LocalizedStringResource = "¿Puedo entrar?"
    static var description = IntentDescription(
        "Responde «entrar» si ya elegiste un tiempo para esa app en NOVEX RISE, o «pausa» si debes hacer la pausa consciente."
    )
    static var openAppWhenRun: Bool = false

    @Parameter(title: "App")
    var app: ControlledApp

    static var parameterSummary: some ParameterSummary {
        Summary("¿Puedo entrar a \(\.$app)?")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let allowed = NovexStore.shared.canEnter(app)
        return .result(value: allowed ? "entrar" : "pausa")
    }
}

/// Abre NOVEX RISE directamente en la pantalla de pausa para esa app.
struct OpenPauseIntent: AppIntent {
    static var title: LocalizedStringResource = "Abrir pausa consciente"
    static var description = IntentDescription(
        "Abre NOVEX RISE con la respiración guiada antes de entrar a la app."
    )
    static var openAppWhenRun: Bool = true

    @Parameter(title: "App")
    var app: ControlledApp

    static var parameterSummary: some ParameterSummary {
        Summary("Abrir pausa consciente para \(\.$app)")
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        AppRouter.shared.presentPause(for: app, mode: .entry)
        return .result()
    }
}
