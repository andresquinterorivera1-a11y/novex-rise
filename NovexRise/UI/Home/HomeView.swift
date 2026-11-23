import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: NovexStore
    @EnvironmentObject private var router: AppRouter
    @State private var showTutorial = false

    var body: some View {
        let today = store.summary(in: NovexStore.todayInterval())

        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header

                if let session = store.state.session, session.isActive() {
                    ActiveSessionCard(session: session) {
                        store.finishSession(exitedOnTime: true)
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    SectionTitle(text: "Hoy")
                    HStack(spacing: 10) {
                        StatTile(value: "\(today.attempts)", label: "Intentos de abrir")
                        StatTile(value: "\(today.declined)", label: "Veces que subiste de nivel")
                        StatTile(value: "\(today.minutesAllowed)", label: "Minutos que elegiste")
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    SectionTitle(text: "Frase del día")
                    Text(Quotes.ofTheDay())
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .novexCard()
                }

                protectedApps

                setupCard
            }
            .padding(20)
        }
        .background(Palette.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showTutorial) {
            NavigationStack {
                ShortcutsTutorialView()
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Cerrar") { showTutorial = false }
                        }
                    }
            }
            .environmentObject(store)
            .environmentObject(router)
            .preferredColorScheme(.dark)
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 14) {
            NovexMarkView()
                .frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 2) {
                NovexWordmark(size: 20)
                Text("No sigas el scroll, marca tu ritmo.")
                    .font(.footnote)
                    .foregroundColor(Palette.secondary)
            }
        }
        .padding(.top, 8)
        .accessibilityElement(children: .combine)
    }

    private var protectedApps: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionTitle(text: "Apps con pausa consciente")
            if store.state.selectedApps.isEmpty {
                Text("Aún no elegiste apps. Ve a Ajustes para añadirlas.")
                    .font(.callout)
                    .foregroundColor(Palette.secondary)
                    .novexCard()
            } else {
                VStack(spacing: 0) {
                    ForEach(store.state.selectedApps) { app in
                        HStack(spacing: 14) {
                            AppBadge(app: app, size: 38)
                            Text(app.name)
                                .font(.body.weight(.semibold))
                                .foregroundColor(.white)
                            Spacer()
                            Button("Probar pausa") {
                                router.presentPause(for: app)
                            }
                            .font(.footnote.weight(.semibold))
                            .foregroundColor(Palette.secondary)
                        }
                        .padding(.vertical, 10)
                        if app != store.state.selectedApps.last {
                            Divider().overlay(Palette.stroke)
                        }
                    }
                }
                .novexCard(padding: 14)
            }
        }
    }

    private var setupCard: some View {
        Button {
            showTutorial = true
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "square.stack.3d.up")
                    .font(.title2)
                    .foregroundColor(.white)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Activa la pausa automática")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Configura Atajos para que NOVEX RISE aparezca al abrir tus apps.")
                        .font(.footnote)
                        .foregroundColor(Palette.secondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Palette.tertiary)
            }
            .novexCard()
        }
        .buttonStyle(.plain)
    }
}

private struct ActiveSessionCard: View {
    let session: ActiveSession
    let onFinish: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                AppBadge(app: session.app, size: 38, filled: true)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sesión activa")
                        .font(.caption.weight(.bold))
                        .foregroundColor(Palette.secondary)
                    Text(session.app.name)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                Spacer()
                Text(timerInterval: session.start...max(session.start, session.end), countsDown: true)
                    .font(.system(size: 30, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.trailing)
            }
            Button("Terminar ahora y subir de nivel", action: onFinish)
                .buttonStyle(.novexSecondary)
        }
        .novexCard()
    }
}
