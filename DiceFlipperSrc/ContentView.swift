import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            ModeToggleView(mode: $appState.mode)
                .padding(.top, 16)
                .padding(.bottom, 8)

            Divider()
                .opacity(0.3)

            ZStack {
                if appState.mode == .coin {
                    CoinFlipView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                } else {
                    DiceRollView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: appState.mode)
        }
    }
}
