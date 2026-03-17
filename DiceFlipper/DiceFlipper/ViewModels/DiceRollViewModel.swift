import SwiftUI

@Observable
class DiceRollViewModel {
    var scale: CGFloat = 1.0
    var isRolling: Bool = false
    var displayResult: Int = 1
    var d6TargetResult: Int = 1
    var d6RollTrigger: Int = 0

    func roll(sides: Int) {
        guard !isRolling else { return }
        isRolling = true
        HapticManager.shared.prepare(.medium)

        let result = Int.random(in: 1...sides)

        if sides == 6 {
            d6TargetResult = result
            d6RollTrigger &+= 1
            return
        }

        withAnimation(.easeIn(duration: 0.35)) {
            scale = 1.15
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.45)) {
                self.scale = 1.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                self.displayResult = result
                HapticManager.shared.impact(.medium)
                self.isRolling = false
            }
        }
    }

    func completeD6Roll() {
        guard isRolling else { return }
        displayResult = d6TargetResult
        HapticManager.shared.impact(.medium)
        isRolling = false
    }
}
