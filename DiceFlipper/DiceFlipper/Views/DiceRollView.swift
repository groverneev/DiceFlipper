import SwiftUI

struct DiceRollView: View {
    @Environment(AppState.self) var appState
    @State private var vm = DiceRollViewModel()

    var body: some View {
        @Bindable var appState = appState
        VStack(spacing: 32) {
            Spacer()

            DiceSidePickerView(sides: $appState.diceSides)

            Spacer()

            Group {
                if appState.diceSides == 6 {
                    // Real 3D cube — handles both static and rolling states internally
                    D6DiceView(result: vm.displayResult, isRolling: vm.isRolling)
                } else {
                    ZStack {
                        DiceFaceView(sides: appState.diceSides, result: vm.displayResult)
                            .opacity(vm.isRolling ? 0 : 1)
                        DiceTumbleView(sides: appState.diceSides, isRolling: vm.isRolling)
                            .opacity(vm.isRolling ? 1 : 0)
                    }
                    .animation(.easeInOut(duration: 0.12), value: vm.isRolling)
                }
            }
            .frame(width: 200, height: 200)
            .scaleEffect(vm.scale)

            Text("Tap or shake")
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(.tertiary)

            Spacer()

            Button {
                vm.roll(sides: appState.diceSides)
            } label: {
                Label("Roll", systemImage: "dice")
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
            .disabled(vm.isRolling)
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .background(ShakeDetector { vm.roll(sides: appState.diceSides) })
        .onChange(of: appState.diceSides) { _, newSides in
            vm.displayResult = min(vm.displayResult, newSides)
            if vm.displayResult < 1 { vm.displayResult = 1 }
        }
    }
}
