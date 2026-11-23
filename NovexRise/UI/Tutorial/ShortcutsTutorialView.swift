import SwiftUI

/// Pantalla con scroll (para Ajustes y para la hoja de Inicio).
struct ShortcutsTutorialView: View {
    var body: some View {
        ScrollView {
            ShortcutsTutorialContent()
                .padding(20)
        }
        .background(Palette.background.ignoresSafeArea())
        .navigationTitle("Pausa automática")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Tutorial para crear UNA automatización en Atajos que cubre todas tus apps.
/// En iOS 26 o posterior basta con una acción; en versiones anteriores hacen falta dos y un «Si».
struct ShortcutsTutorialContent: View {
    @EnvironmentObject private var store: NovexStore
    @EnvironmentObject private var router: AppRouter
    @Environment(\.openURL) private var openURL

    private static let shortcutsURL = URL(string: "shortcuts://")

    private var apps: [ControlledApp] {
        store.state.selectedApps.isEmpty ? [.instagram, .tiktok, .youtube] : store.state.selectedApps
    }

    private var appNames: String {
        apps.map(\.name).joined(separator: ", ")
    }

    private var supportsOneAction: Bool {
        if #available(iOS 26.0, *) { return true }
        return false
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Haz que la pausa aparezca sola")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                Text(supportsOneAction
                     ? "Una sola automatización para todas tus apps. Se hace una vez y tarda 1 minuto."
                     : "Una sola automatización para todas tus apps. Se hace una vez y tarda 2 minutos.")
                    .font(.callout)
                    .foregroundColor(Palette.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            commonSteps

            if supportsOneAction {
                TutorialStep(number: 4, title: "«Nueva automatización en blanco» → añade «Pausa NOVEX RISE»", detail: "Busca «NOVEX» en las acciones y tócala. No cambies nada más. Toca «OK» y listo.") {
                    MockActionBlock(lines: [("arrow.up.right", "Pausa NOVEX RISE")])
                }
            } else {
                legacySteps
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("¿Cómo sabe a qué app ibas?")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("Después de respirar te pregunta qué app ibas a abrir. Cuando eliges un tiempo, te deja pasar sin repetir la pausa hasta que se acabe.")
                    .font(.footnote)
                    .foregroundColor(Palette.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .novexCard()

            VStack(alignment: .leading, spacing: 8) {
                Text("¿Por qué no se activa sola como Ascent?")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("Ascent usa el permiso de Tiempo en pantalla de Apple, que solo se concede a apps de la App Store con cuenta de desarrollador de pago. Instalada gratis, NOVEX RISE necesita esta automatización, que solo tú puedes crear.")
                    .font(.footnote)
                    .foregroundColor(Palette.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .novexCard()

            VStack(spacing: 12) {
                Button("Abrir Atajos") {
                    if let url = Self.shortcutsURL { openURL(url) }
                }
                .buttonStyle(.novexPrimary)

                Button("Probar la pausa ahora") {
                    router.presentPause(for: nil)
                }
                .buttonStyle(.novexSecondary)
            }
        }
    }

    // MARK: - Pasos 1 a 3 (iguales en todas las versiones)

    @ViewBuilder
    private var commonSteps: some View {
        TutorialStep(number: 1, title: "Abre Atajos y toca «Automatización»", detail: "Está en la barra de abajo de la app Atajos.") {
            MockTabBar(items: ["Atajos", "Automatización", "Galería"], highlighted: 1)
        }

        TutorialStep(number: 2, title: "Toca «+» y elige «App»", detail: "Si es tu primera automatización, toca «Nueva automatización».") {
            VStack(spacing: 8) {
                MockRow(icon: "clock", text: "Hora del día")
                MockRow(icon: "alarm", text: "Alarma")
                MockRow(icon: "square.grid.2x2", text: "App", highlighted: true)
            }
        }

        TutorialStep(number: 3, title: "Marca TODAS tus apps, «Se abre» y «Ejecutar inmediatamente»", detail: "En «Elegir» marca \(appNames) y toca «OK». Desactiva «Notificar al ejecutar» si aparece. Luego toca «Siguiente».") {
            VStack(spacing: 8) {
                ForEach(apps) { app in
                    MockRow(icon: "checkmark.circle.fill", text: app.name, highlighted: true)
                }
                MockRow(icon: "checkmark.circle.fill", text: "Se abre", highlighted: true)
                MockRow(icon: "bolt.fill", text: "Ejecutar inmediatamente", highlighted: true)
            }
        }
    }

    // MARK: - iOS 18 o anterior

    @ViewBuilder
    private var legacySteps: some View {
        TutorialStep(number: 4, title: "«Nueva automatización en blanco» → añade «¿Puedo entrar?»", detail: "Busca «NOVEX» en las acciones. Deja la app vacía.") {
            MockActionBlock(lines: [("arrow.up.right", "¿Puedo entrar?")])
        }

        TutorialStep(number: 5, title: "Añade la acción «Si»", detail: "Condición: Si [Resultado] es «pausa». Escribe la palabra pausa tal cual, en minúsculas.") {
            MockActionBlock(lines: [("arrow.triangle.branch", "Si  Resultado  es  pausa")])
        }

        TutorialStep(number: 6, title: "Dentro del «Si», añade «Abrir pausa consciente»", detail: "Es otra acción de NOVEX RISE. Deja la app vacía. Toca «OK» y listo.") {
            MockActionBlock(lines: [
                ("arrow.triangle.branch", "Si  Resultado  es  pausa"),
                ("arrow.up.right", "    Abrir pausa consciente"),
                ("minus", "Fin de si")
            ])
        }
    }
}

// MARK: - Piezas de las ilustraciones

private struct TutorialStep<Illustration: View>: View {
    let number: Int
    let title: String
    let detail: String
    @ViewBuilder let illustration: () -> Illustration

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Text("\(number)")
                    .font(.subheadline.weight(.black))
                    .foregroundColor(.black)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(Color.white))
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(detail)
                        .font(.footnote)
                        .foregroundColor(Palette.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            MockScreen(content: illustration)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct MockScreen<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 8) {
            Capsule()
                .fill(Palette.stroke)
                .frame(width: 44, height: 4)
                .padding(.bottom, 4)
            content()
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(white: 0.10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Palette.stroke, lineWidth: 1)
        )
        .padding(.leading, 40)
    }
}

private struct MockRow: View {
    let icon: String
    let text: String
    var highlighted = false

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
        .foregroundColor(highlighted ? .black : .white)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(highlighted ? Color.white : Palette.raised)
        )
    }
}

private struct MockTabBar: View {
    let items: [String]
    let highlighted: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(items, id: \.self) { item in
                let isHighlighted = items.indices.contains(highlighted) && items[highlighted] == item
                Text(item)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .foregroundColor(isHighlighted ? .black : Palette.secondary)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(
                        Capsule().fill(isHighlighted ? Color.white : Color.clear)
                    )
            }
        }
    }
}

private struct MockLine: Identifiable {
    let icon: String
    let text: String

    var id: String { text }
}

private struct MockActionBlock: View {
    let lines: [MockLine]

    init(lines: [(String, String)]) {
        self.lines = lines.map { MockLine(icon: $0.0, text: $0.1) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(lines) { line in
                HStack(spacing: 10) {
                    Image(systemName: line.icon)
                        .frame(width: 20)
                    Text(line.text)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(2)
                    Spacer()
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Palette.raised)
                )
            }
        }
    }
}
