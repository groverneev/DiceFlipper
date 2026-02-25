import SwiftUI

struct ResultDisplayView: View {
    let value: String
    let color: Color

    var body: some View {
        Text(value)
            .font(.system(size: 120, weight: .black, design: .rounded))
            .foregroundStyle(color)
            .contentTransition(.numericText())
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: value)
    }
}
