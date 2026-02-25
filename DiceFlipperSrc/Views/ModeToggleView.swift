import SwiftUI

struct ModeToggleView: View {
    @Binding var mode: AppMode

    var body: some View {
        HStack(spacing: 0) {
            modeButton(label: "Coin", icon: "circle.fill", target: .coin)
            modeButton(label: "Dice", icon: "dice.fill", target: .dice)
        }
        .background(Color(.systemGray6))
        .clipShape(Capsule())
        .padding(.horizontal, 24)
    }

    private func modeButton(label: String, icon: String, target: AppMode) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                mode = target
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(label)
                    .fontWeight(.semibold)
            }
            .font(.system(size: 15, design: .rounded))
            .foregroundStyle(mode == target ? .white : .secondary)
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(mode == target ? Color.accentColor : Color.clear)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: mode == target)
            )
        }
        .buttonStyle(.plain)
    }
}
