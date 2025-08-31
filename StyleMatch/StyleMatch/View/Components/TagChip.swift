import SwiftUI

struct TagChip: View {
    let label: String
    let isSelected: Bool
    var selectable: Bool = true
    var action: (() -> Void)?

    var body: some View {
        Button {
            action?()
        } label: {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue : Color.gray.opacity(0.1))
                )
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected ? Color.blue : Color.gray.opacity(0.2),
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
        .disabled(!selectable)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

