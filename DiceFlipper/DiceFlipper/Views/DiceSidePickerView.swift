import SwiftUI

struct DiceSidePickerView: View {
    @Binding var sides: Int
    @State private var showCustomField = false
    @State private var customText = ""

    private let presets = [4, 6, 8, 10, 12, 20]

    var body: some View {
        VStack(spacing: 10) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(presets, id: \.self) { n in
                        pillButton(label: "d\(n)", selected: sides == n && !showCustomField) {
                            showCustomField = false
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                sides = n
                            }
                        }
                    }
                    pillButton(label: showCustomField ? "d\(sides)" : "Custom", selected: showCustomField) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showCustomField.toggle()
                        }
                        customText = ""
                    }
                }
                .padding(.horizontal, 20)
            }

            if showCustomField {
                HStack {
                    TextField("Enter sides", text: $customText)
                        .keyboardType(.numberPad)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .frame(width: 120)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .onChange(of: customText) { _, newValue in
                            if let n = Int(newValue), n >= 2, n <= 1000 {
                                sides = n
                            }
                        }

                    Button("Done") {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showCustomField = false
                        }
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.accentColor)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    private func pillButton(label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(selected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(selected ? Color.accentColor : Color(.systemGray5))
                )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selected)
    }
}
