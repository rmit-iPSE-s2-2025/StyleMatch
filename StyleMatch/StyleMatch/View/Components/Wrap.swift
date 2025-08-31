import SwiftUI

struct Wrap: View {
    let tags: [String]
    @Binding var selection: Set<String>
    var isSelectable: Bool = true

    @State private var totalHeight: CGFloat = .zero

    var body: some View {
        VStack {
            GeometryReader { geo in generateContent(in: geo) }
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width: CGFloat = .zero
        var height: CGFloat = .zero

        return ZStack(alignment: .topLeading) {
            ForEach(tags, id: \.self) { tag in
                let sel = selection.contains(tag)
                TagChip(label: tag, isSelected: sel, selectable: isSelectable) {
                    if sel { selection.remove(tag) } else { selection.insert(tag) }
                }
                .alignmentGuide(.leading) { d in
                    if width + d.width > g.size.width { width = 0; height -= d.height + 8 }
                    let res = width
                    if tag == tags.last { width = 0 }
                    return res
                }
                .alignmentGuide(.top) { _ in
                    let res = height
                    if tag == tags.last { height = 0 }
                    return res
                }
            }
        }
        .background(GeometryReader { proxy in
            Color.clear.onAppear { totalHeight = proxy.size.height }
        })
    }
}

