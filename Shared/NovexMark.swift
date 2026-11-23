import SwiftUI

/// Símbolo de NOVEX RISE: una línea que sube en zigzag y termina en flecha.
struct NovexRiseMark: Shape {
    func path(in rect: CGRect) -> Path {
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + rect.width * x, y: rect.minY + rect.height * y)
        }

        var path = Path()
        // Línea ascendente
        path.move(to: point(0.08, 0.84))
        path.addLine(to: point(0.38, 0.54))
        path.addLine(to: point(0.56, 0.70))
        path.addLine(to: point(0.88, 0.18))
        // Punta de flecha
        path.move(to: point(0.62, 0.18))
        path.addLine(to: point(0.88, 0.18))
        path.addLine(to: point(0.88, 0.44))
        return path
    }
}

/// El símbolo ya dibujado, con un grosor de línea proporcional a su tamaño.
struct NovexMarkView: View {
    var color: Color = .white

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            NovexRiseMark()
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: max(1.5, side * 0.09), lineCap: .round, lineJoin: .round)
                )
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }
}
