import SwiftUI

struct DiceFaceView: View {
    let sides: Int
    let result: Int

    var body: some View {
        ZStack {
            diceShape
            diceLabel
        }
        .frame(width: 200, height: 200)
    }

    // MARK: - Shape layer

    @ViewBuilder
    private var diceShape: some View {
        switch sides {
        case 4:
            PolygonDie(sides: 3, rotationOffset: -90,
                       colors: [Color(hex: "F97316"), Color(hex: "EF4444")],
                       shadowColor: Color(hex: "F97316"))
        case 6:
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(LinearGradient(colors: [Color(hex: "4F46E5"), Color(hex: "7C3AED")],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .strokeBorder(.white.opacity(0.15), lineWidth: 2))
                .shadow(color: Color(hex: "4F46E5").opacity(0.5), radius: 20, x: 0, y: 8)
        case 8:
            PolygonDie(sides: 4, rotationOffset: -45,
                       colors: [Color(hex: "3B82F6"), Color(hex: "1D4ED8")],
                       shadowColor: Color(hex: "3B82F6"))
        case 10:
            PolygonDie(sides: 5, rotationOffset: 90,
                       colors: [Color(hex: "14B8A6"), Color(hex: "0891B2")],
                       shadowColor: Color(hex: "14B8A6"))
        case 12:
            PolygonDie(sides: 5, rotationOffset: -90,
                       colors: [Color(hex: "22C55E"), Color(hex: "15803D")],
                       shadowColor: Color(hex: "22C55E"))
        case 20:
            PolygonDie(sides: 3, rotationOffset: 90,
                       colors: [Color(hex: "6366F1"), Color(hex: "4338CA")],
                       shadowColor: Color(hex: "6366F1"))
        default:
            // Non-standard die — rendered as a glowing orb (circle = infinite sides)
            Circle()
                .fill(LinearGradient(colors: [Color(hex: "6B7280"), Color(hex: "374151")],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(Circle().strokeBorder(.white.opacity(0.15), lineWidth: 2))
                .shadow(color: Color(hex: "6B7280").opacity(0.5), radius: 20, x: 0, y: 8)
        }
    }

    // MARK: - Label layer

    @ViewBuilder
    private var diceLabel: some View {
        if sides == 6 {
            D6DotsView(value: result)
        } else {
            VStack(spacing: 4) {
                Text("d\(sides)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
                Text("\(result)")
                    .font(.system(size: 72, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
    }
}

// MARK: - Polygon die shape + fill

private struct PolygonDie: View {
    let sides: Int
    let rotationOffset: Double   // degrees — controls which vertex points up
    let colors: [Color]
    let shadowColor: Color

    var body: some View {
        RegularPolygon(sides: sides, rotationOffset: rotationOffset)
            .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay(
                RegularPolygon(sides: sides, rotationOffset: rotationOffset)
                    .stroke(.white.opacity(0.15), lineWidth: 2)
            )
            .shadow(color: shadowColor.opacity(0.5), radius: 20, x: 0, y: 8)
    }
}

// MARK: - Regular polygon path

private struct RegularPolygon: Shape {
    let sides: Int
    let rotationOffset: Double   // degrees

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let angleStep = (2 * .pi) / Double(sides)
        let startAngle = rotationOffset * (.pi / 180)

        var path = Path()
        for i in 0..<sides {
            let angle = startAngle + Double(i) * angleStep
            let point = CGPoint(
                x: center.x + CGFloat(cos(angle)) * radius,
                y: center.y + CGFloat(sin(angle)) * radius
            )
            if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - D6 pip layout

private struct D6DotsView: View {
    let value: Int

    private let dotSize: CGFloat = 22
    private let dotColor = Color.white

    var body: some View {
        let layout = dotLayout(for: value)
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let pad: CGFloat = 32

            ForEach(Array(layout.enumerated()), id: \.offset) { _, pos in
                Circle()
                    .fill(dotColor)
                    .frame(width: dotSize, height: dotSize)
                    .position(
                        x: pad + pos.x * (w - pad * 2),
                        y: pad + pos.y * (h - pad * 2)
                    )
            }
        }
    }

    func dotLayout(for value: Int) -> [CGPoint] {
        switch value {
        case 1: return [CGPoint(x: 0.5, y: 0.5)]
        case 2: return [CGPoint(x: 0.25, y: 0.25), CGPoint(x: 0.75, y: 0.75)]
        case 3: return [CGPoint(x: 0.25, y: 0.25), CGPoint(x: 0.5, y: 0.5), CGPoint(x: 0.75, y: 0.75)]
        case 4: return [CGPoint(x: 0.25, y: 0.25), CGPoint(x: 0.75, y: 0.25),
                        CGPoint(x: 0.25, y: 0.75), CGPoint(x: 0.75, y: 0.75)]
        case 5: return [CGPoint(x: 0.25, y: 0.25), CGPoint(x: 0.75, y: 0.25),
                        CGPoint(x: 0.5,  y: 0.5),
                        CGPoint(x: 0.25, y: 0.75), CGPoint(x: 0.75, y: 0.75)]
        case 6: return [CGPoint(x: 0.25, y: 0.2),  CGPoint(x: 0.75, y: 0.2),
                        CGPoint(x: 0.25, y: 0.5),  CGPoint(x: 0.75, y: 0.5),
                        CGPoint(x: 0.25, y: 0.8),  CGPoint(x: 0.75, y: 0.8)]
        default: return []
        }
    }
}
