import SwiftUI

class DiceRollViewModel: ObservableObject {
    @Published var rotationDegrees: Double = 0
    @Published var scale: CGFloat = 1.0
    @Published var isRolling: Bool = false
    @Published var displayResult: Int = 1

    func roll(sides: Int) {
        guard !isRolling else { return }
        isRolling = true
        HapticManager.shared.prepare(.medium)

        let result = Int.random(in: 1...sides)

        withAnimation(.easeIn(duration: 0.35)) {
            rotationDegrees += 1080
            scale = 1.15
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.45)) {
                self.rotationDegrees += 45
                self.scale = 1.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                self.displayResult = result
                HapticManager.shared.impact(.medium)
                self.isRolling = false
            }
        }
    }
}
