import Foundation

enum SortOption: String, CaseIterable {
    case relevance = "Relevance"
    case priceLowToHigh = "Price: Low to High"
    case priceHighToLow = "Price: High to Low"
    case newest = "Newest"
}

enum FilterOption: Hashable {
    case brand(String)
    case priceRange(ClosedRange<Double>)
    case color(String)
    case fit(String)
    case gender(String)
}

final class Catalog: ObservableObject {
    @Published var products: [Product] = []
    @Published var saved: Set<UUID> = []
    @Published var recentSearches: [String] = [] {
        didSet { UserDefaults.standard.set(recentSearches, forKey: "recent_searches_v1") }
    }
    
    // Filter and sort state
    @Published var selectedSort: SortOption = .relevance
    @Published var activeFilters: [FilterOption] = []
    @Published var searchQuery: String = ""
    
    // Comparison feature
    @Published var comparisonItems: [Product] = []
    
    // Computed properties
    var availableBrands: [String] {
        Array(Set(products.map { $0.brand })).sorted()
    }
    
    var availableColors: [String] {
        Array(Set(products.flatMap { $0.colors })).sorted()
    }
    
    var availableFits: [String] {
        Array(Set(products.flatMap { $0.tags.filter { ["oversized", "relaxed", "fitted", "loose"].contains($0) } })).sorted()
    }
    
    var filteredAndSortedProducts: [Product] {
        var filtered = products
        
        // Apply filters
        for filter in activeFilters {
            switch filter {
            case .brand(let brand):
                filtered = filtered.filter { $0.brand == brand }
            case .priceRange(let range):
                filtered = filtered.filter { range.contains($0.price) }
            case .color(let color):
                filtered = filtered.filter { $0.colors.contains(color) }
            case .fit(let fit):
                filtered = filtered.filter { $0.tags.contains(fit) }
            case .gender(let gender):
                filtered = filtered.filter { $0.gender == gender }
            }
        }
        
        // Apply search query
        if !searchQuery.isEmpty {
            let searchResults = searchProducts(query: searchQuery, products: filtered)
            filtered = searchResults.map { $0.product }
        }
        
        // Apply sorting
        switch selectedSort {
        case .relevance:
            if !searchQuery.isEmpty {
                let searchResults = searchProducts(query: searchQuery, products: filtered)
                filtered = searchResults.map { $0.product }
            }
        case .priceLowToHigh:
            filtered.sort { $0.price < $1.price }
        case .priceHighToLow:
            filtered.sort { $0.price > $1.price }
        case .newest:
            // Assuming products are already sorted by newest first
            break
        }
        
        return filtered
    }

    init() {
        loadProducts()
        recentSearches = UserDefaults.standard.stringArray(forKey: "recent_searches_v1") ?? []
    }

    func toggleSaved(_ id: UUID) {
        if saved.contains(id) { 
            saved.remove(id) 
        } else { 
            saved.insert(id) 
        }
        saveSavedItems()
    }
    
    func addToComparison(_ product: Product) {
        if comparisonItems.count < 2 && !comparisonItems.contains(where: { $0.id == product.id }) {
            comparisonItems.append(product)
        }
    }
    
    func removeFromComparison(_ product: Product) {
        comparisonItems.removeAll { $0.id == product.id }
    }
    
    func clearComparison() {
        comparisonItems.removeAll()
    }

    func addRecent(_ q: String) {
        let s = q.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !s.isEmpty else { return }
        recentSearches.removeAll { $0.caseInsensitiveCompare(s) == .orderedSame }
        recentSearches.insert(s, at: 0)
        if recentSearches.count > 8 { recentSearches.removeLast(recentSearches.count - 8) }
    }
    
    func applyFilter(_ filter: FilterOption) {
        activeFilters.append(filter)
    }
    
    func removeFilter(_ filter: FilterOption) {
        activeFilters.removeAll { filter in
            switch (filter, filter) {
            case (.brand(let b1), .brand(let b2)): return b1 == b2
            case (.color(let c1), .color(let c2)): return c1 == c2
            case (.fit(let f1), .fit(let f2)): return f1 == f2
            case (.gender(let g1), .gender(let g2)): return g1 == g2
            case (.priceRange(let r1), .priceRange(let r2)): return r1 == r2
            default: return false
            }
        }
    }
    
    func clearAllFilters() {
        activeFilters.removeAll()
    }

    private func loadProducts() {
        guard let url = Bundle.main.url(forResource: "products", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Product].self, from: data) else {
            print("⚠️ Failed to load products.json")
            return
        }
        products = decoded
    }
    
    private func saveSavedItems() {
        let savedIds = Array(saved).map { $0.uuidString }
        UserDefaults.standard.set(savedIds, forKey: "saved_items_v1")
    }
}

