import SwiftUI

enum AppMode {
    case coin, dice
}

enum CoinFace {
    case heads, tails
}

class AppState: ObservableObject {
    @Published var mode: AppMode = .coin
    @Published var diceSides: Int = 6
}
