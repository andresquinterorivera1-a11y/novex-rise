import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: NovexStore
    @State private var newGoal = ""

    var body: some View {
        Form {
            Section {
                ForEach(ControlledApp.allCases) { app in
                    Toggle(isOn: selectionBinding(for: app)) {
                        Label(app.name, systemImage: app.symbol)
                    }
                }
            } header: {
                Text("Apps con pausa consciente")
            } footer: {
                Text("Si añades una app, márcala también en tu automatización de Atajos (abajo).")
            }

            Section {
                ForEach(store.state.goals, id: \.self) { goal in
                    Text(goal)
                }
                .onDelete { offsets in
                    store.removeGoals(at: offsets)
                }

                if store.state.goals.count < NovexStore.maxGoals {
                    HStack {
                        TextField("Nueva meta, ej.: Entrenar", text: $newGoal)
                            .submitLabel(.done)
                            .onSubmit(addGoal)
                        Button("Añadir", action: addGoal)
                            .disabled(newGoal.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            } header: {
                Text("Tus metas")
            } footer: {
                Text("Te las recordamos en la pausa: «¿Esto te acerca a tu meta?»")
            }

            Section {
                Stepper(value: breathingBinding, in: 5...10) {
                    Text("Respiración: \(store.state.breathingSeconds) s")
                }
                NavigationLink("Configurar pausa automática con Atajos") {
                    ShortcutsTutorialView()
                }
            } header: {
                Text("Pausa")
            }

            Section {
                Label("Todo se guarda solo en este iPhone.", systemImage: "lock")
                Label("Sin cuentas, sin anuncios, sin rastreo.", systemImage: "eye.slash")
            } header: {
                Text("Privacidad")
            }

            Section {
                LabeledContent("Versión", value: "NOVEX RISE Lite 0.2")
                Text("El bloqueo total con la Screen Time API de Apple llegará en la versión completa.")
                    .font(.footnote)
                    .foregroundColor(Palette.secondary)
            } header: {
                Text("Acerca de")
            }
        }
        .scrollContentBackground(.hidden)
        .background(Palette.background.ignoresSafeArea())
        .navigationTitle("Ajustes")
    }

    private func selectionBinding(for app: ControlledApp) -> Binding<Bool> {
        Binding(
            get: { store.isSelected(app) },
            set: { store.setSelected(app, $0) }
        )
    }

    private var breathingBinding: Binding<Int> {
        Binding(
            get: { store.state.breathingSeconds },
            set: { store.setBreathingSeconds($0) }
        )
    }

    private func addGoal() {
        store.addGoal(newGoal)
        newGoal = ""
    }
}
