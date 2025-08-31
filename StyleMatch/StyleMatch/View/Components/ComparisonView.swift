import SwiftUI

struct ComparisonView: View {
    @EnvironmentObject var catalog: Catalog
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if catalog.comparisonItems.isEmpty {
                        // Empty state
                        VStack(spacing: 20) {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 64, weight: .light))
                                .foregroundStyle(.secondary)
                            
                            Text("No Items to Compare")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.primary)
                            
                            Text("Select items from your saved list to compare them side by side")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 60)
                    } else if catalog.comparisonItems.count == 1 {
                        // Single item state
                        VStack(spacing: 20) {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 48, weight: .light))
                                .foregroundStyle(.secondary)
                            
                            Text("Add Another Item")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.primary)
                            
                            Text("Select one more item to start comparing")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                            
                            // Show the single item
                            ComparisonItemCard(item: catalog.comparisonItems[0])
                        }
                        .padding(.top, 40)
                    } else {
                        // Comparison view
                        VStack(spacing: 20) {
                            // Header
                            HStack {
                                Text("Comparing \(catalog.comparisonItems.count) Items")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                                
                                Button {
                                    catalog.clearComparison()
                                } label: {
                                    Text("Clear")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(.red)
                                }
                            }
                            
                            // Comparison grid
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: catalog.comparisonItems.count), spacing: 16) {
                                ForEach(catalog.comparisonItems) { item in
                                    ComparisonItemCard(item: item)
                                }
                            }
                            
                            // Comparison details
                            ComparisonDetailsView(items: catalog.comparisonItems)
                        }
                    }
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Compare Items")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// Comparison Item Card Component
struct ComparisonItemCard: View {
    let item: Product
    @EnvironmentObject var catalog: Catalog
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image
            Image(item.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
            
            // Product info
            VStack(alignment: .leading, spacing: 6) {
                Text(item.brand)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                
                Text(item.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(String(format: "$%.0f", item.price))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.primary)
            }
            
            // Remove button
            Button {
                catalog.removeFromComparison(item)
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "minus.circle")
                        .font(.system(size: 12, weight: .medium))
                    Text("Remove")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundStyle(.red)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
    }
}

// Comparison Details Component
struct ComparisonDetailsView: View {
    let items: [Product]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Details")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.primary)
            
            // Price comparison
            ComparisonRow(
                title: "Price",
                values: items.map { String(format: "$%.0f", $0.price) }
            )
            
            // Brand comparison
            ComparisonRow(
                title: "Brand",
                values: items.map { $0.brand }
            )
            
            // Gender comparison
            ComparisonRow(
                title: "Gender",
                values: items.map { $0.gender.capitalized }
            )
            
            // Colors comparison
            ComparisonRow(
                title: "Colors",
                values: items.map { $0.colors.joined(separator: ", ") }
            )
            
            // Tags comparison
            ComparisonRow(
                title: "Style Tags",
                values: items.map { $0.tags.joined(separator: ", ") }
            )
        }
    }
}

// Comparison Row Component
struct ComparisonRow: View {
    let title: String
    let values: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
            
            HStack(spacing: 12) {
                ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                    Text(value)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
}
