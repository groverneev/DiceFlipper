import SwiftUI

struct CoinFlipView: View {
    @StateObject private var vm = CoinFlipViewModel()

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            Text(vm.coinResult == .heads ? "Heads" : "Tails")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .opacity(vm.isFlipping ? 0 : 1)
                .animation(.easeInOut(duration: 0.2), value: vm.isFlipping)

            CoinFaceView(face: vm.displayedFace)
                .rotation3DEffect(
                    .degrees(vm.rotationAngle),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.5
                )

            Text("Tap or shake")
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(.tertiary)

            Spacer()

            Button {
                vm.flip()
            } label: {
                Label("Flip", systemImage: "arrow.triangle.2.circlepath")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        Capsule()
                            .fill(Color.accentColor)
                            .shadow(color: Color.accentColor.opacity(0.4), radius: 12, x: 0, y: 6)
                    )
            }
            .buttonStyle(.plain)
            .disabled(vm.isFlipping)
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .background(ShakeDetector { vm.flip() })
    }
}
