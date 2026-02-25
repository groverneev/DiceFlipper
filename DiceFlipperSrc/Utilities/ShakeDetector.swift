import SwiftUI
import UIKit

struct ShakeDetector: UIViewControllerRepresentable {
    var onShake: () -> Void

    func makeUIViewController(context: Context) -> ShakeViewController {
        let vc = ShakeViewController()
        vc.onShake = onShake
        return vc
    }

    func updateUIViewController(_ uiViewController: ShakeViewController, context: Context) {
        uiViewController.onShake = onShake
    }
}

class ShakeViewController: UIViewController {
    var onShake: (() -> Void)?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }

    override var canBecomeFirstResponder: Bool { true }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            onShake?()
        }
    }
}
