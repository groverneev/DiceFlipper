import SwiftUI

class CoinFlipViewModel: ObservableObject {
    @Published var rotationAngle: Double = 0
    @Published var isFlipping: Bool = false
    @Published var coinResult: CoinFace = .heads

    var displayedFace: CoinFace {
        let normalized = rotationAngle.truncatingRemainder(dividingBy: 360)
        let positive = normalized < 0 ? normalized + 360 : normalized
        let showingBack = positive > 90 && positive < 270
        let baseIsHeads = coinResult == .heads
        return showingBack ? (baseIsHeads ? .tails : .heads) : (baseIsHeads ? .heads : .tails)
    }

    func flip() {
        guard !isFlipping else { return }
        isFlipping = true
        HapticManager.shared.prepare(.heavy)

        let result: CoinFace = Bool.random() ? .heads : .tails

        withAnimation(.easeIn(duration: 0.4)) {
            rotationAngle += 900
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            let base = self.rotationAngle - self.rotationAngle.truncatingRemainder(dividingBy: 360)
            let targetOffset: Double = result == .heads ? 0 : 180

            withAnimation(.easeOut(duration: 0.5)) {
                self.rotationAngle = base + targetOffset
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                self.coinResult = result
                HapticManager.shared.impact(.heavy)
                self.isFlipping = false
            }
        }
    }
}
