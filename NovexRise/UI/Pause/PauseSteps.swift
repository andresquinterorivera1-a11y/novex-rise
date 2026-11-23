import SwiftUI

// MARK: - ¿Qué app ibas a abrir?

/// Aparece cuando una sola automatización cubre varias apps
/// y NOVEX RISE no sabe cuál abriste.
struct AppChoiceStepView: View {
    let apps: [ControlledApp]
    let onSelect: (ControlledApp) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    var body: some View {
        VStack(spacing: 20) {
            NovexLogo(markSize: 34)
                .padding(.top, 12)

            Spacer(minLength: 0)

            Text("¿Qué app ibas a abrir?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text("Ponerle nombre al impulso ya es tomar el control.")
                .font(.callout)
                .foregroundColor(Palette.secondary)
                .multilineTextAlignment(.center)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(apps) { app in
                        Button {
                            onSelect(app)
                        } label: {
                            VStack(spacing: 8) {
                                AppBadge(app: app, size: 48)
                                Text(app.name)
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                            .frame(maxWidth: .infinity, minHeight: 96)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Palette.card)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Palette.stroke, lineWidth: 1)
                            )
                            .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(app.name)
                    }
                }
            }

            Spacer(minLength: 0)
        }
    }
}

// MARK: - ¿De verdad quieres entrar?

struct QuestionStepView: View {
    let app: ControlledApp
    let attemptNumber: Int
    let goal: String?
    let quote: String
    let onEnter: () -> Void
    let onDecline: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            NovexLogo(markSize: 34)
                .padding(.top, 12)

            Spacer(minLength: 8)

            AppBadge(app: app, size: 64)

            Text(attemptText)
                .font(.subheadline)
                .foregroundColor(Palette.secondary)
                .multilineTextAlignment(.center)

            Text("¿De verdad quieres entrar?")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)

            if let goal {
                VStack(spacing: 6) {
                    Text("¿Esto te acerca a tu meta?")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Palette.secondary)
                    Text("«\(goal)»")
                        .font(.title3.weight(.bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .novexCard(padding: 16)
            }

            QuoteView(text: quote)

            Spacer(minLength: 8)

            VStack(spacing: 12) {
                Button("No, hoy subo de nivel", action: onDecline)
                    .buttonStyle(.novexPrimary)
                Button("Sí, quiero entrar", action: onEnter)
                    .buttonStyle(.novexSecondary)
            }
        }
    }

    private var attemptText: String {
        attemptNumber <= 1
            ? "Es la primera vez que intentas abrir \(app.name) hoy."
            : "Es la \(attemptNumber).ª vez que intentas abrir \(app.name) hoy."
    }
}

// MARK: - ¿Cuánto tiempo?

struct DurationStepView: View {
    let app: ControlledApp
    let onBack: () -> Void
    let onContinue: (Int) -> Void

    @State private var selection: Int?
    @State private var isCustom = false
    @State private var customMinutes = 20

    private let presets = [1, 5, 10, 15, 30]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    var body: some View {
        VStack(spacing: 22) {
            HStack {
                Button(action: onBack) {
                    Label("Atrás", systemImage: "chevron.left")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundColor(Palette.secondary)
                Spacer()
            }
            .padding(.top, 12)

            Spacer(minLength: 0)

            Text("¿Cuánto tiempo quieres estar en \(app.name)?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text("Elige con intención. Te avisamos 1 minuto antes de que termine.")
                .font(.callout)
                .foregroundColor(Palette.secondary)
                .multilineTextAlignment(.center)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(presets, id: \.self) { minutes in
                    ChoiceChip(title: "\(minutes)", subtitle: "min", isSelected: !isCustom && selection == minutes) {
                        isCustom = false
                        selection = minutes
                    }
                }
                ChoiceChip(title: "+", subtitle: "Otro", isSelected: isCustom) {
                    isCustom = true
                }
            }

            if isCustom {
                Stepper(value: $customMinutes, in: 1...120) {
                    Text("\(customMinutes) minutos")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .novexCard(padding: 14)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            Spacer(minLength: 0)

            Button("Continuar") {
                if let chosen { onContinue(chosen) }
            }
            .buttonStyle(.novexPrimary)
            .disabled(chosen == nil)
        }
        .animation(.easeInOut(duration: 0.25), value: isCustom)
    }

    private var chosen: Int? {
        isCustom ? customMinutes : selection
    }
}

// MARK: - ¿Para qué vas a entrar?

struct IntentionStepView: View {
    let isStarting: Bool
    let onSelect: (Intention?) -> Void

    var body: some View {
        VStack(spacing: 20) {
            NovexLogo(markSize: 34)
                .padding(.top, 12)

            Spacer(minLength: 0)

            Text("¿Para qué vas a entrar?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text("Es opcional. Te ayuda a ver tus patrones en las estadísticas.")
                .font(.callout)
                .foregroundColor(Palette.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                ForEach(Intention.allCases) { intention in
                    Button {
                        onSelect(intention)
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: intention.symbol)
                                .frame(width: 24)
                            Text(intention.label)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.footnote.weight(.bold))
                                .foregroundColor(Palette.tertiary)
                        }
                    }
                    .buttonStyle(.novexSecondary)
                }
            }

            Spacer(minLength: 0)

            if isStarting {
                ProgressView()
                    .tint(.white)
            } else {
                Button("Omitir") { onSelect(nil) }
                    .buttonStyle(.novexGhost)
            }
        }
        .disabled(isStarting)
    }
}

// MARK: - Se acabó tu tiempo

struct TimeUpStepView: View {
    let app: ControlledApp
    let canExtend: Bool
    let onExit: () -> Void
    let onExtend: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            NovexLogo(markSize: 34)
                .padding(.top, 12)

            Spacer()

            Image(systemName: "hourglass.bottomhalf.filled")
                .font(.system(size: 54, weight: .light))
                .foregroundColor(.white)
                .accessibilityHidden(true)

            Text("Se acabó tu tiempo.")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text(canExtend
                 ? "¿Sales de \(app.name) o necesitas 2 minutos más?"
                 : "Ya usaste tu extensión en esta sesión. Es momento de salir.")
                .font(.callout)
                .foregroundColor(Palette.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            VStack(spacing: 12) {
                Button("Salgo, subo de nivel", action: onExit)
                    .buttonStyle(.novexPrimary)
                if canExtend {
                    Button("2 minutos más", action: onExtend)
                        .buttonStyle(.novexSecondary)
                }
            }
        }
    }
}

// MARK: - Resultado (subiste de nivel / saliste a tiempo)

struct ResultStepView: View {
    let title: String
    let message: String
    let quote: String
    let onDone: () -> Void

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 22) {
            Spacer()

            NovexMarkView()
                .frame(width: 96, height: 96)
                .scaleEffect(appeared ? 1 : 0.6)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 24)

            Text(title)
                .font(.system(size: 34, weight: .black))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text(message)
                .font(.callout)
                .foregroundColor(Palette.secondary)
                .multilineTextAlignment(.center)

            QuoteView(text: quote)
                .padding(.top, 8)

            Spacer()

            Button("Listo", action: onDone)
                .buttonStyle(.novexPrimary)

            Text("Desliza hacia arriba para volver a tu pantalla de inicio.")
                .font(.footnote)
                .foregroundColor(Palette.tertiary)
                .multilineTextAlignment(.center)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { appeared = true }
        }
    }
}
