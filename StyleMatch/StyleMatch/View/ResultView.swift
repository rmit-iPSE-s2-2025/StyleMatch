import SwiftUI

struct ResultsView: View {
    @EnvironmentObject var catalog: Catalog
    let refTags: Set<String>
    @State private var showingFilters = false
    @State private var showingSort = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Results header with search terms and controls
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Found \(scoredProducts().count) matches")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.primary)
                            
                            if !refTags.isEmpty {
                                Text("Based on: \(Array(refTags).joined(separator: ", "))")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                        }
                        
                        Spacer()
                        
                        // Filter and Sort buttons
                        HStack(spacing: 12) {
                            Button {
                                showingSort = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.up.arrow.down")
                                        .font(.system(size: 14, weight: .medium))
                                    Text(catalog.selectedSort.rawValue)
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                            
                            Button {
                                showingFilters = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "line.3.horizontal.decrease.circle")
                                        .font(.system(size: 14, weight: .medium))
                                    Text("Filter")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    // Active filters display
                    if !catalog.activeFilters.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Active Filters")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.primary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(catalog.activeFilters, id: \.self) { filter in
                                        FilterChip(filter: filter) {
                                            catalog.removeFilter(filter)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Results grid
                if scoredProducts().isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48, weight: .light))
                            .foregroundStyle(.secondary)
                        
                        Text("No matches found")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.primary)
                        
                        Text("Try adjusting your search terms or filters")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 60)
                } else {
                    Masonry2Col {
                        ForEach(scoredProducts(), id: \.item.id) { pair in
                            NavigationLink(value: pair.item) {
                                ProductCard(item: pair.item, score: pair.score)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Style Matches")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: Product.self) { item in
            DetailView(item: item)
        }
        .sheet(isPresented: $showingFilters) {
            FilterView()
        }
        .sheet(isPresented: $showingSort) {
            SortView()
        }
    }

    private func scoredProducts() -> [(item: Product, score: Int)] {
        catalog.products
            .map { ($0, tagOverlapScore(ref: refTags, tags: $0.tags, colors: $0.colors)) }
            .sorted { $0.1 > $1.1 }
    }
}

// Filter Chip Component
struct FilterChip: View {
    let filter: FilterOption
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Text(filterLabel)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.primary)
            
            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(
            Capsule()
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var filterLabel: String {
        switch filter {
        case .brand(let brand): return brand
        case .color(let color): return color
        case .fit(let fit): return fit
        case .gender(let gender): return gender
        case .priceRange(let range): return "$\(Int(range.lowerBound))-$\(Int(range.upperBound))"
        }
    }
}

