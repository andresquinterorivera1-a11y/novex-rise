import SwiftUI

/// Onboarding de 5 pantallas:
/// bienvenida → metas → apps → notificaciones → tutorial de Atajos.
struct OnboardingView: View {
    @EnvironmentObject private var store: NovexStore
    @State private var page = 0

    private let pageCount = 5

    var body: some View {
        VStack(spacing: 0) {
            topBar

            Group {
                switch page {
                case 0: WelcomePage(onNext: next)
                case 1: GoalsPage(onNext: next)
                case 2: AppsPage(onNext: next)
                case 3: NotificationsPage(onNext: next)
                default: TutorialPage(onFinish: store.completeOnboarding)
                }
            }
            .id(page)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
        }
        .background(Palette.background.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.35), value: page)
    }

    private var topBar: some View {
        HStack {
            Button {
                page = max(0, page - 1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .frame(width: 44, height: 44)
            }
            .foregroundColor(Palette.secondary)
            .opacity(page > 0 ? 1 : 0)
            .disabled(page == 0)
            .accessibilityLabel("Atrás")

            Spacer()

            HStack(spacing: 6) {
                ForEach(0..<pageCount, id: \.self) { index in
                    Capsule()
                        .fill(index <= page ? Color.white : Palette.stroke)
                        .frame(width: index == page ? 22 : 8, height: 8)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Paso \(page + 1) de \(pageCount)")

            Spacer()

            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 12)
    }

    private func next() {
        page = min(pageCount - 1, page + 1)
    }
}

// MARK: - 1. Bienvenida

private struct WelcomePage: View {
    let onNext: () -> Void
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            NovexMarkView()
                .frame(width: 120, height: 120)
                .scaleEffect(appeared ? 1 : 0.7)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 30)

            VStack(spacing: 14) {
                Text("Bienvenido a")
                    .font(.title3)
                    .foregroundColor(Palette.secondary)
                NovexWordmark(size: 34)
                Text("No sigas el scroll,\nmarca tu ritmo.")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .opacity(appeared ? 1 : 0)

            Spacer()

            Text("Antes de abrir una red social, NOVEX RISE te da una pausa para decidir si de verdad quieres entrar y cuánto tiempo.")
                .font(.callout)
                .foregroundColor(Palette.secondary)
                .multilineTextAlignment(.center)

            Button("Empezar", action: onNext)
                .buttonStyle(.novexPrimary)
        }
        .padding(24)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75)) { appeared = true }
        }
    }
}

// MARK: - 2. Metas

private struct GoalsPage: View {
    let onNext: () -> Void
    @EnvironmentObject private var store: NovexStore
    @State private var draft = ""
    @FocusState private var isFieldFocused: Bool

    private let suggestions = ["Hacer crecer mi negocio", "Entrenar", "Estudiar", "Dormir mejor", "Leer más", "Pasar tiempo con mi familia"]
    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 8)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("¿Qué quieres lograr?")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                    Text("Te lo recordaremos en cada pausa: «¿Esto te acerca a tu meta?»")
                        .font(.callout)
                        .foregroundColor(Palette.secondary)
                }

                HStack(spacing: 10) {
                    TextField("Escribe una meta", text: $draft)
                        .focused($isFieldFocused)
                        .submitLabel(.done)
                        .onSubmit(add)
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Palette.card))
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Palette.stroke))
                    Button(action: add) {
                        Image(systemName: "plus")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(width: 50, height: 50)
                            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.white))
                    }
                    .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty)
                    .accessibilityLabel("Añadir meta")
                }

                if !store.state.goals.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(store.state.goals, id: \.self) { goal in
                            HStack {
                                Image(systemName: "arrow.up.right")
                                Text(goal)
                                    .font(.body.weight(.semibold))
                                Spacer()
                                Button {
                                    store.removeGoal(goal)
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.footnote.weight(.bold))
                                        .foregroundColor(Palette.secondary)
                                        .frame(width: 32, height: 32)
                                }
                                .accessibilityLabel("Quitar \(goal)")
                            }
                            .foregroundColor(.white)
                            .novexCard(padding: 12)
                        }
                    }
                }

                SectionTitle(text: "Ideas")
                LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                    ForEach(suggestions.filter { !store.state.goals.contains($0) }, id: \.self) { suggestion in
                        Button {
                            store.addGoal(suggestion)
                        } label: {
                            Text(suggestion)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .background(Capsule().stroke(Palette.stroke))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(24)
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
            Button(store.state.goals.isEmpty ? "Ahora no" : "Continuar", action: onNext)
                .buttonStyle(NovexButtonStyle(kind: store.state.goals.isEmpty ? .secondary : .primary))
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
                .background(Palette.background)
        }
    }

    private func add() {
        store.addGoal(draft)
        draft = ""
        isFieldFocused = false
    }
}

// MARK: - 3. Apps

private struct AppsPage: View {
    let onNext: () -> Void
    @EnvironmentObject private var store: NovexStore

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("¿Qué apps te roban el ritmo?")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                    Text("Antes de abrirlas aparecerá la pausa consciente.")
                        .font(.callout)
                        .foregroundColor(Palette.secondary)
                }

                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(ControlledApp.allCases) { app in
                        let selected = store.isSelected(app)
                        Button {
                            store.setSelected(app, !selected)
                        } label: {
                            VStack(spacing: 10) {
                                AppBadge(app: app, size: 46, filled: selected)
                                Text(app.name)
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(selected ? .white : Palette.secondary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(selected ? Palette.raised : Palette.card)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(selected ? Color.white : Palette.stroke, lineWidth: selected ? 1.5 : 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .animation(.easeInOut(duration: 0.2), value: selected)
                        .accessibilityLabel(app.name)
                        .accessibilityAddTraits(selected ? .isSelected : [])
                    }
                }
            }
            .padding(24)
        }
        .safeAreaInset(edge: .bottom) {
            Button("Continuar", action: onNext)
                .buttonStyle(.novexPrimary)
                .disabled(store.state.selectedApps.isEmpty)
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
                .background(Palette.background)
        }
    }
}

// MARK: - 4. Permisos

private struct NotificationsPage: View {
    let onNext: () -> Void
    @State private var isRequesting = false

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            Spacer()

            Image(systemName: "bell")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(.white)

            Text("Avisos para marcar tu ritmo")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 14) {
                PermissionReason(icon: "timer", text: "Te avisamos 1 minuto antes de que se acabe el tiempo que elegiste.")
                PermissionReason(icon: "hourglass", text: "Cuando termina, te preguntamos: «¿Sales o necesitas 2 minutos más?».")
                PermissionReason(icon: "iphone", text: "Verás la cuenta regresiva en la pantalla de bloqueo y la Isla Dinámica.")
                PermissionReason(icon: "lock", text: "Todo ocurre en tu iPhone. Nada se envía a ningún servidor.")
            }

            Spacer()

            Button {
                isRequesting = true
                Task {
                    await NotificationService.requestAuthorization()
                    isRequesting = false
                    onNext()
                }
            } label: {
                if isRequesting {
                    ProgressView().tint(.black)
                } else {
                    Text("Permitir avisos")
                }
            }
            .buttonStyle(.novexPrimary)
            .disabled(isRequesting)

            Button("Ahora no", action: onNext)
                .buttonStyle(.novexGhost)
        }
        .padding(24)
    }
}

private struct PermissionReason: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 26)
            Text(text)
                .font(.callout)
                .foregroundColor(Palette.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - 5. Tutorial de Atajos

private struct TutorialPage: View {
    let onFinish: () -> Void

    var body: some View {
        ScrollView {
            ShortcutsTutorialContent()
                .padding(24)
        }
        .safeAreaInset(edge: .bottom) {
            Button("Listo, empezar a subir", action: onFinish)
                .buttonStyle(.novexPrimary)
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
                .background(Palette.background)
        }
    }
}
