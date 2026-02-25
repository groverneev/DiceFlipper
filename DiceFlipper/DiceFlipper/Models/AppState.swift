import SwiftUI
import Observation

enum AppMode {
    case coin, dice
}

enum CoinFace {
    case heads, tails
}

@Observable
class AppState {
    var mode: AppMode = .coin
    var diceSides: Int = 6
}
