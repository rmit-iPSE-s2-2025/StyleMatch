import SwiftUI

struct DetailView: View {
    @EnvironmentObject var catalog: Catalog
    let item: Product
    @State private var showingComparison = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Product image with enhanced styling
                Image(item.imageName)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)

                // Product header with improved layout
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.brand)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.5)
                        
                        Text(item.name)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Text(String(format: "$%.0f", item.price))
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.primary)
                    }
                    
                    Spacer()
                    
                    // Action buttons
                    VStack(spacing: 12) {
                        Button { catalog.toggleSaved(item.id) } label: {
                            Image(systemName: catalog.saved.contains(item.id) ? "heart.fill" : "heart")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundStyle(catalog.saved.contains(item.id) ? .red : .secondary)
                                .padding(12)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        .buttonStyle(.plain)
                        
                        // Compare button
                        if catalog.saved.contains(item.id) {
                            Button {
                                if catalog.comparisonItems.contains(where: { $0.id == item.id }) {
                                    catalog.removeFromComparison(item)
                                } else {
                                    catalog.addToComparison(item)
                                }
                            } label: {
                                Image(systemName: catalog.comparisonItems.contains(where: { $0.id == item.id }) ? "minus.circle.fill" : "plus.circle")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundStyle(catalog.comparisonItems.contains(where: { $0.id == item.id }) ? .red : .blue)
                                    .padding(12)
                                    .background(.ultraThinMaterial, in: Circle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // Tags section with improved styling
                if !item.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Style Tags")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.primary)
                        Wrap(tags: item.tags, selection: .constant([]), isSelectable: false)
                    }
                }

                // Product description with enhanced typography
                Text("A \(item.colors.first ?? "") \(item.name.lowercased()) by \(item.brand). Designed for \(item.gender). Great for \(item.tags.joined(separator: ", ")).")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.secondary)
                    .lineSpacing(4)
                    .padding(.vertical, 8)

                // Comparison section (if item is saved)
                if catalog.saved.contains(item.id) && !catalog.comparisonItems.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Comparison")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Button {
                                showingComparison = true
                            } label: {
                                Text("View All")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(.blue)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(catalog.comparisonItems.prefix(3)) { compareItem in
                                    ComparisonPreviewCard(item: compareItem)
                                }
                            }
                        }
                    }
                }

                // Related items with improved styling
                VStack(alignment: .leading, spacing: 16) {
                    Text("You Might Also Like")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(related(), id: \.id) { rel in
                                NavigationLink(value: rel) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Image(rel.imageName)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 150, height: 150)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                                            )
                                        
                                        Text(rel.brand)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundStyle(.secondary)
                                            .textCase(.uppercase)
                                            .tracking(0.5)
                                        
                                        Text(rel.name)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundStyle(.primary)
                                            .lineLimit(2)
                                            .multilineTextAlignment(.leading)
                                    }
                                    .frame(width: 150)
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
        .navigationTitle(item.brand)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingComparison) {
            ComparisonView()
        }
    }

    private func related() -> [Product] {
        catalog.products
            .filter { $0.id != item.id }
            .map { ($0, tagOverlapScore(ref: Set(item.tags.map{$0.lowercased()}), tags: $0.tags, colors: $0.colors)) }
            .sorted { $0.1 > $1.1 }
            .prefix(10)
            .map { $0.0 }
    }
}

// Comparison Preview Card Component
struct ComparisonPreviewCard: View {
    let item: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(item.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
            
            Text(item.name)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            Text(String(format: "$%.0f", item.price))
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.primary)
        }
        .frame(width: 80)
    }
}

