import SwiftUI

struct NightSkyBackground: View {
    private let cities: [UnitPoint] = [
        UnitPoint(x: 0.22, y: 0.30), UnitPoint(x: 0.55, y: 0.25), UnitPoint(x: 0.82, y: 0.33),
    ]

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack {
                Color.trekNight
                aurora(Color.trekIndigo, opacity: 0.75, diameter: size.width * 0.95, at: CGPoint(x: size.width * 0.1, y: size.height * 0.08))
                aurora(Color.trekViolet, opacity: 0.35, diameter: size.width * 0.7, at: CGPoint(x: size.width * 0.35, y: size.height * 0.5))
                aurora(Color.trekCyan, opacity: 0.45, diameter: size.width * 0.85, at: CGPoint(x: size.width * 0.95, y: size.height * 0.82))
                dotMap
                route(in: size)
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    private func aurora(_ color: Color, opacity: Double, diameter: CGFloat, at center: CGPoint) -> some View {
        Circle()
            .fill(RadialGradient(colors: [color.opacity(opacity), color.opacity(0)], center: .center, startRadius: 0, endRadius: diameter / 2))
            .frame(width: diameter, height: diameter)
            .blur(radius: 40)
            .position(center)
    }

    private var dotMap: some View {
        Canvas { context, size in
            let spacing: CGFloat = 7
            for x in stride(from: spacing / 2, to: size.width, by: spacing) {
                for y in stride(from: spacing / 2, to: size.height, by: spacing) {
                    context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 1.4, height: 1.4)), with: .color(.white.opacity(0.22)))
                }
            }
        }
        .mask {
            RadialGradient(colors: [.black, .clear], center: UnitPoint(x: 0.55, y: 0.32), startRadius: 20, endRadius: 330)
        }
        .opacity(0.6)
    }

    private func route(in size: CGSize) -> some View {
        let points = cities.map { CGPoint(x: $0.x * size.width, y: $0.y * size.height) }
        return ZStack {
            Path { path in
                path.move(to: CGPoint(x: -20, y: points[0].y + 30))
                path.addQuadCurve(to: CGPoint(x: size.width + 20, y: points[2].y + 20), control: CGPoint(x: size.width / 2, y: points[1].y - 70))
            }
            .stroke(Color(hex: 0xA5B4FC).opacity(0.45), lineWidth: 1)

            ForEach(points.indices, id: \.self) { index in
                Circle()
                    .fill(.white)
                    .frame(width: 5, height: 5)
                    .shadow(color: Color(hex: 0xA5B4FC).opacity(0.9), radius: 6)
                    .position(points[index])
            }
        }
    }
}
