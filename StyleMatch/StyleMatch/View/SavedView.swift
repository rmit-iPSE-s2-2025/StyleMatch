import SwiftUI

struct SavedView: View {
    @EnvironmentObject var catalog: Catalog
    @State private var showingComparison = false
    @State private var selectedItems: Set<UUID> = []
    
    private var savedItems: [Product] { catalog.products.filter { catalog.saved.contains($0.id) } }

    var body: some View {
        Group {
            if savedItems.isEmpty {
                // Empty state with improved styling
                VStack(spacing: 24) {
                    Image(systemName: "heart")
                        .font(.system(size: 64, weight: .light))
                        .foregroundStyle(.secondary)
                    
                    VStack(spacing: 8) {
                        Text("No Saved Items")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.primary)
                        
                        Text("Items you save will appear here")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
            } else {
                // Saved items list with enhanced styling
                ScrollView {
                    VStack(spacing: 20) {
                        // Header with comparison button
                        HStack {
                            Text("Saved Items (\(savedItems.count))")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            if !catalog.comparisonItems.isEmpty {
                                Button {
                                    showingComparison = true
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "square.and.pencil")
                                            .font(.system(size: 14, weight: .medium))
                                        Text("Compare (\(catalog.comparisonItems.count))")
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
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        // Saved items
                        LazyVStack(spacing: 16) {
                            ForEach(savedItems) { item in
                                SavedItemRow(
                                    item: item,
                                    isSelected: selectedItems.contains(item.id),
                                    onToggleSelection: {
                                        if selectedItems.contains(item.id) {
                                            selectedItems.remove(item.id)
                                            catalog.removeFromComparison(item)
                                        } else {
                                            selectedItems.insert(item.id)
                                            catalog.addToComparison(item)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .background(Color(.systemGroupedBackground))
            }
        }
        .navigationTitle("Saved Items")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: Product.self) { item in
            DetailView(item: item)
        }
        .sheet(isPresented: $showingComparison) {
            ComparisonView()
        }
    }
}

// Enhanced Saved Item Row Component
struct SavedItemRow: View {
    let item: Product
    let isSelected: Bool
    let onToggleSelection: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Selection checkbox
            Button(action: onToggleSelection) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(isSelected ? .blue : .secondary)
            }
            .buttonStyle(.plain)
            
            // Product image
            Image(item.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
            
            // Product info
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(item.brand)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                
                Text(String(format: "$%.0f", item.price))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.primary)
            }
            
            Spacer()
            
            // Navigation chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
        .opacity(isSelected ? 0.8 : 1.0)
        .scaleEffect(isSelected ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

