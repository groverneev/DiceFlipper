import SwiftUI

struct DiceFaceView: View {
    let sides: Int
    let result: Int

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "4F46E5"), Color(hex: "7C3AED")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(.white.opacity(0.15), lineWidth: 2)
                )
                .shadow(color: Color(hex: "4F46E5").opacity(0.5), radius: 20, x: 0, y: 8)

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
        .frame(width: 200, height: 200)
    }
}

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
