import SwiftUI

struct Masonry2Col: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 320
        let colW = (width - 16 - 16 - 12) / 2
        var heights = (left: CGFloat(0), right: CGFloat(0))
        for v in subviews {
            let s = v.sizeThatFits(.init(width: colW, height: nil))
            if heights.left <= heights.right { heights.left += s.height + 12 } else { heights.right += s.height + 12 }
        }
        return .init(width: width, height: max(heights.left, heights.right))
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let colW = (bounds.width - 16 - 16 - 12) / 2
        var y = (left: bounds.minY, right: bounds.minY)
        for v in subviews {
            let s = v.sizeThatFits(.init(width: colW, height: nil))
            if y.left <= y.right {
                v.place(at: CGPoint(x: bounds.minX + 16, y: y.left), anchor: .topLeading,
                        proposal: .init(width: colW, height: s.height))
                y.left += s.height + 12
            } else {
                v.place(at: CGPoint(x: bounds.minX + 16 + colW + 12, y: y.right), anchor: .topLeading,
                        proposal: .init(width: colW, height: s.height))
                y.right += s.height + 12
            }
        }
    }
}

