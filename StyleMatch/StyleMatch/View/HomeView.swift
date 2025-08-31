import SwiftUI

struct HomeView: View {
    @EnvironmentObject var catalog: Catalog
    @State private var query: String = ""
    @State private var selectedTags: Set<String> = []
    private let quickTags = ["hoodie","oversized","black","streetwear","tshirt","white","casual","summer","denim","unisex"]

    // Compute the ref tags outside the destination (keeps ViewBuilder happy)
    private var computedRef: Set<String> {
        tokenize(query).union(selectedTags)
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                // App Title with improved typography
                Text("StyleMatch")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .padding(.top, 8)

                // Search row with enhanced styling
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 16, weight: .medium))
                    TextField("Search styles (e.g. black hoodie)", text: $query)
                        .textInputAutocapitalization(.never)
                        .font(.system(size: 16, weight: .regular))
                }
                .padding(16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )

                // Quick tags section with better labeling
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Filters")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.primary)
                    Wrap(tags: quickTags, selection: $selectedTags)
                }

                // Actions with improved button styling
                VStack(spacing: 12) {
                    NavigationLink { ScanView() } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 16, weight: .medium))
                            Text("Use Reference Photo")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    // Destination returns a View only
                    NavigationLink {
                        ResultsView(refTags: computedRef)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 16, weight: .medium))
                            Text("Find Matches")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .disabled(query.isEmpty && selectedTags.isEmpty)
                    // Side-effect (saving recent) happens on tap, not in destination
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            if !query.isEmpty { catalog.addRecent(query) }
                        }
                    )
                }

                // Recent searches with improved styling
                if !catalog.recentSearches.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Searches")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.primary)
                        Wrap(tags: catalog.recentSearches,
                             selection: .constant([]),
                             isSelectable: false)
                    }
                }

                // Featured items with enhanced styling
                VStack(alignment: .leading, spacing: 16) {
                    Text("Featured Styles")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.primary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(catalog.products.prefix(8)) { item in
                                NavigationLink(value: item) {
                                    ProductCard(item: item)
                                        .frame(width: 240)
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        // Deep link to detail when tapping any Product
        .navigationDestination(for: Product.self) { item in
            DetailView(item: item)
        }
        // Use ToolbarItemGroup to avoid overload ambiguity
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {   // use .topBarTrailing on iOS 17+
                NavigationLink(destination: SavedView()) {
                    Image(systemName: "heart")
                        .font(.system(size: 18, weight: .medium))
                }
            }
        }
    }
}

