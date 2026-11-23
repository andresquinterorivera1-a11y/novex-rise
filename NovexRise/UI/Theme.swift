import SwiftUI

/// Paleta de NOVEX RISE: solo blanco, negro y grises. Menos estímulo, más claridad.
enum Palette {
    static let background = Color.black
    static let foreground = Color.white
    static let secondary = Color(white: 0.62)
    static let tertiary = Color(white: 0.40)
    static let card = Color(white: 0.075)
    static let raised = Color(white: 0.12)
    static let stroke = Color(white: 0.20)
}

// MARK: - Botones

struct NovexButtonStyle: ButtonStyle {
    enum Kind { case primary, secondary, ghost }

    var kind: Kind = .primary

    func makeBody(configuration: Configuration) -> some View {
        StyledLabel(configuration: configuration, kind: kind)
    }

    private struct StyledLabel: View {
        let configuration: ButtonStyleConfiguration
        let kind: Kind
        @Environment(\.isEnabled) private var isEnabled

        var body: some View {
            configuration.label
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, minHeight: 54)
                .foregroundColor(foreground)
                .background(background)
                .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .opacity(isEnabled ? (configuration.isPressed ? 0.75 : 1) : 0.35)
                .scaleEffect(configuration.isPressed ? 0.98 : 1)
                .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
        }

        private var foreground: Color {
            kind == .primary ? .black : .white
        }

        @ViewBuilder private var background: some View {
            let shape = RoundedRectangle(cornerRadius: 16, style: .continuous)
            switch kind {
            case .primary:
                shape.fill(Color.white)
            case .secondary:
                shape.fill(Palette.card).overlay(shape.stroke(Palette.stroke, lineWidth: 1))
            case .ghost:
                Color.clear
            }
        }
    }
}

extension ButtonStyle where Self == NovexButtonStyle {
    static var novexPrimary: NovexButtonStyle { NovexButtonStyle(kind: .primary) }
    static var novexSecondary: NovexButtonStyle { NovexButtonStyle(kind: .secondary) }
    static var novexGhost: NovexButtonStyle { NovexButtonStyle(kind: .ghost) }
}

// MARK: - Tarjetas

extension View {
    func novexCard(padding: CGFloat = 18) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Palette.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Palette.stroke, lineWidth: 1)
            )
    }
}
