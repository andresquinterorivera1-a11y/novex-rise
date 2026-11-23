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

/// Tutorial paso a paso para crear la automatización en la app Atajos.
/// Cada paso lleva una ilustración simplificada de lo que verás en pantalla.
struct ShortcutsTutorialContent: View {
    @EnvironmentObject private var store: NovexStore
    @EnvironmentObject private var router: AppRouter
    @Environment(\.openURL) private var openURL

    private static let shortcutsURL = URL(string: "shortcuts://")

    private var exampleApp: ControlledApp {
        store.state.selectedApps.first ?? .instagram
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Haz que la pausa aparezca sola")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                Text("Con una automatización de Atajos, cada vez que abras \(exampleApp.name) aparecerá NOVEX RISE primero. Se hace una vez por app y tarda 2 minutos.")
                    .font(.callout)
                    .foregroundColor(Palette.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            TutorialStep(number: 1, title: "Abre Atajos y toca «Automatización»", detail: "Está en la barra de abajo de la app Atajos.") {
                MockTabBar(items: ["Atajos", "Automatización", "Galería"], highlighted: 1)
            }

            TutorialStep(number: 2, title: "Toca «+» o «Nueva automatización» y elige «App»", detail: "Si ya tienes automatizaciones, el botón «+» está arriba a la derecha.") {
                VStack(spacing: 8) {
                    MockRow(icon: "clock", text: "Hora del día")
                    MockRow(icon: "alarm", text: "Alarma")
                    MockRow(icon: "square.grid.2x2", text: "App", highlighted: true)
                }
            }

            TutorialStep(number: 3, title: "Elige \(exampleApp.name), marca «Se abre» y «Ejecutar inmediatamente»", detail: "Desactiva «Notificar al ejecutar» si aparece. Luego toca «Siguiente».") {
                VStack(spacing: 8) {
                    MockRow(icon: exampleApp.symbol, text: "App: \(exampleApp.name)")
                    MockRow(icon: "checkmark.circle.fill", text: "Se abre", highlighted: true)
                    MockRow(icon: "circle", text: "Se cierra")
                    MockRow(icon: "bolt.fill", text: "Ejecutar inmediatamente", highlighted: true)
                }
            }

            TutorialStep(number: 4, title: "«Nueva automatización en blanco» → añade «¿Puedo entrar?»", detail: "Busca «NOVEX RISE» en las acciones y elige la misma app.") {
                MockActionBlock(lines: [("arrow.up.right", "¿Puedo entrar a \(exampleApp.name)?")])
            }

            TutorialStep(number: 5, title: "Añade la acción «Si»", detail: "Condición: Si [Resultado] es «pausa». Escribe la palabra pausa tal cual, en minúsculas.") {
                MockActionBlock(lines: [("arrow.triangle.branch", "Si  Resultado  es  pausa")])
            }

            TutorialStep(number: 6, title: "Dentro del «Si», añade «Abrir pausa consciente»", detail: "Es otra acción de NOVEX RISE. Elige otra vez \(exampleApp.name). Toca «OK» y listo.") {
                MockActionBlock(lines: [
                    ("arrow.triangle.branch", "Si  Resultado  es  pausa"),
                    ("arrow.up.right", "    Abrir pausa consciente para \(exampleApp.name)"),
                    ("minus", "Fin de si")
                ])
            }

            TutorialStep(number: 7, title: "Repite con cada app", detail: "Crea una automatización por app (cambia la app en los pasos 3, 4 y 6).") {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(store.state.selectedApps) { app in
                        HStack(spacing: 10) {
                            AppBadge(app: app, size: 28)
                            Text(app.name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                    if store.state.selectedApps.isEmpty {
                        Text("Elige tus apps en Ajustes.")
                            .font(.footnote)
                            .foregroundColor(Palette.secondary)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("¿Por qué el «Si»?")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("Cuando eliges un tiempo, NOVEX RISE responde «entrar» y Atajos te deja pasar sin repetir la pausa. Cuando el tiempo se acaba, vuelve a responder «pausa».")
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
                    router.presentPause(for: exampleApp)
                }
                .buttonStyle(.novexSecondary)
            }
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
