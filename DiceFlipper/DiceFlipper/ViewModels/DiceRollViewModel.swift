import SwiftUI

@Observable
class DiceRollViewModel {
    var yRotation: Double = 0
    var xRotation: Double = 0
    var scale: CGFloat = 1.0
    var isRolling: Bool = false
    var displayResult: Int = 1

    func roll(sides: Int) {
        guard !isRolling else { return }
        isRolling = true
        HapticManager.shared.prepare(.medium)

        let result = Int.random(in: 1...sides)

        // Phase 1: tumble through the air — 2 full Y-spins + 20° overshoot, 1 full X-tilt
        withAnimation(.easeIn(duration: 0.35)) {
            yRotation += 740   // 720° (2 spins) + 20° overshoot
            xRotation += 360   // 1 full forward tilt
            scale = 1.15
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            // Phase 2: spring back from overshoot — die "lands" and wobbles to rest face-up
            withAnimation(.spring(response: 0.45, dampingFraction: 0.45)) {
                self.yRotation -= 20   // correct overshoot → lands at multiple of 360° (face-up)
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
