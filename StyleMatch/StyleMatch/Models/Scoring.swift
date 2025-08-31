import Foundation

func tokenize(_ text: String) -> Set<String> {
    Set(text.lowercased().split { !$0.isLetter && !$0.isNumber }.map(String.init))
}

func tagOverlapScore(ref: Set<String>, tags: [String], colors: [String]) -> Int {
    let t = Set(tags.map { $0.lowercased() })
    let c = Set(colors.map { $0.lowercased() })
    
    // Direct matches
    let tagMatches = ref.intersection(t).count
    let colorMatches = ref.intersection(c).count
    
    // Partial matches (fuzzy matching)
    let partialMatches = ref.reduce(0) { score, query in
        let matchingTags = t.filter { $0.contains(query) || query.contains($0) }
        let matchingColors = c.filter { $0.contains(query) || query.contains($0) }
        return score + matchingTags.count + matchingColors.count
    }
    
    return tagMatches + colorMatches + (partialMatches / 2) // Weight partial matches less
}

enum Confidence: String {
    case close = "Close Match"
    case medium = "Good Match"
    case loose = "Loose Match"
}

func confidence(for score: Int) -> Confidence {
    switch score {
    case 5...: return .close
    case 3...4: return .medium
    default: return .loose
    }
}

// Enhanced search with multiple criteria
struct SearchResult {
    let product: Product
    let score: Int
    let confidence: Confidence
    let matchedTags: [String]
    let matchedColors: [String]
}

func searchProducts(query: String, products: [Product]) -> [SearchResult] {
    let tokens = tokenize(query)
    guard !tokens.isEmpty else { return [] }
    
    return products.map { product in
        let score = tagOverlapScore(ref: tokens, tags: product.tags, colors: product.colors)
        let matchedTags = product.tags.filter { tag in
            tokens.contains { token in
                tag.lowercased().contains(token) || token.contains(tag.lowercased())
            }
        }
        let matchedColors = product.colors.filter { color in
            tokens.contains { token in
                color.lowercased().contains(token) || token.contains(color.lowercased())
            }
        }
        
        return SearchResult(
            product: product,
            score: score,
            confidence: confidence(for: score),
            matchedTags: matchedTags,
            matchedColors: matchedColors
        )
    }
    .filter { $0.score > 0 }
    .sorted { $0.score > $1.score }
}

