import SwiftUI

struct CoinFaceView: View {
    let face: CoinFace

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: face == .heads
                            ? [Color(hex: "FFD700"), Color(hex: "B8860B")]
                            : [Color(hex: "C0C0C0"), Color(hex: "707070")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Circle()
                        .strokeBorder(
                            face == .heads ? Color(hex: "B8860B") : Color(hex: "505050"),
                            lineWidth: 4
                        )
                )
                .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)

            Text(face == .heads ? "H" : "T")
                .font(.system(size: 80, weight: .black, design: .serif))
                .foregroundStyle(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 2)
        }
        .frame(width: 220, height: 220)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
