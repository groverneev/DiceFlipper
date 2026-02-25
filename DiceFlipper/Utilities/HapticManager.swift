import UIKit

final class HapticManager {
    static let shared = HapticManager()
    private init() {}

    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let g = UIImpactFeedbackGenerator(style: style)
        g.prepare()
        g.impactOccurred()
    }

    func prepare(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let g = UIImpactFeedbackGenerator(style: style)
        g.prepare()
    }
}
