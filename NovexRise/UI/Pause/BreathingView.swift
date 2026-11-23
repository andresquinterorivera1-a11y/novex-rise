import SwiftUI

/// Respiración guiada de 5 a 10 segundos. No se puede saltar.
struct BreathingView: View {
    let seconds: Int
    let onFinish: () -> Void

    @State private var expanded = false
    @State private var inhaling = true
    @State private var remaining: Int

    init(seconds: Int, onFinish: @escaping () -> Void) {
        self.seconds = seconds
        self.onFinish = onFinish
        _remaining = State(initialValue: seconds)
    }

    var body: some View {
        VStack(spacing: 32) {
            NovexLogo(markSize: 34)
                .padding(.top, 12)

            Spacer()

            ZStack {
                Circle()
                    .stroke(Palette.stroke, lineWidth: 1)
                    .frame(width: 270, height: 270)

                Circle()
                    .fill(Color.white.opacity(0.06))
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .frame(width: 270, height: 270)
                    .scaleEffect(expanded ? 1.0 : 0.42)

                VStack(spacing: 6) {
                    Text(inhaling ? "Inhala" : "Exhala")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.white)
                    Text("\(remaining)")
                        .font(.system(size: 46, weight: .bold, design: .rounded).monospacedDigit())
                        .foregroundColor(.white)
                        .contentTransition(.numericText())
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(inhaling ? "Inhala" : "Exhala")
            .accessibilityValue("\(remaining) segundos")

            Text("Respira. Tú decides, no el scroll.")
                .font(.callout)
                .foregroundColor(Palette.secondary)

            Spacer()
        }
        .task { await breathe() }
    }

    private func breathe() async {
        let total = max(1, seconds)
        let half = Double(total) / 2
        withAnimation(.easeInOut(duration: half)) { expanded = true }

        for elapsed in 0..<total {
            if inhaling, Double(elapsed) >= half {
                inhaling = false
                withAnimation(.easeInOut(duration: Double(total - elapsed))) { expanded = false }
            }
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            if Task.isCancelled { return }
            withAnimation { remaining = total - elapsed - 1 }
        }
        onFinish()
    }
}
