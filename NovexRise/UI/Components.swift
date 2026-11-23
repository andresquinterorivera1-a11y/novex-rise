import SwiftUI

/// "NOVEX RISE" en mayúsculas, negrita y con espaciado amplio.
struct NovexWordmark: View {
    var size: CGFloat = 22

    var body: some View {
        Text("NOVEX RISE")
            .font(.system(size: size, weight: .black))
            .tracking(size * 0.18)
            .foregroundColor(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }
}

/// Logo completo: flecha ascendente + nombre.
struct NovexLogo: View {
    var markSize: CGFloat = 56
    var showsWordmark = true

    var body: some View {
        VStack(spacing: markSize * 0.28) {
            NovexMarkView()
                .frame(width: markSize, height: markSize)
            if showsWordmark {
                NovexWordmark(size: max(12, markSize * 0.38))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("NOVEX RISE")
    }
}

/// Ícono genérico de la app controlada dentro de un círculo.
struct AppBadge: View {
    let app: ControlledApp
    var size: CGFloat = 44
    var filled = false

    var body: some View {
        Image(systemName: app.symbol)
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundColor(filled ? .black : .white)
            .frame(width: size, height: size)
            .background(Circle().fill(filled ? Color.white : Palette.raised))
            .overlay(Circle().stroke(filled ? Color.white : Palette.stroke, lineWidth: 1))
            .accessibilityHidden(true)
    }
}

struct StatTile: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(.system(size: 30, weight: .bold, design: .rounded).monospacedDigit())
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(label)
                .font(.caption)
                .foregroundColor(Palette.secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .novexCard(padding: 14)
        .accessibilityElement(children: .combine)
    }
}

struct QuoteView: View {
    let text: String

    var body: some View {
        Text("“\(text)”")
            .font(.callout.italic())
            .foregroundColor(Palette.secondary)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 8)
    }
}

struct SectionTitle: View {
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(.caption.weight(.bold))
            .tracking(1.5)
            .foregroundColor(Palette.tertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader)
    }
}

/// Opción grande seleccionable (minutos, apps…).
struct ChoiceChip: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                Text(subtitle)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, minHeight: 84)
            .foregroundColor(isSelected ? .black : .white)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isSelected ? Color.white : Palette.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? Color.white : Palette.stroke, lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .accessibilityLabel("\(title) \(subtitle)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
