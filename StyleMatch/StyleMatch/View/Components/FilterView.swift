import SwiftUI

struct FilterView: View {
    @EnvironmentObject var catalog: Catalog
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedBrands: Set<String> = []
    @State private var selectedColors: Set<String> = []
    @State private var selectedFits: Set<String> = []
    @State private var selectedGenders: Set<String> = []
    @State private var priceRange: ClosedRange<Double> = 0...200
    
    private let priceRanges: [ClosedRange<Double>] = [
        0...50,
        50...100,
        100...150,
        150...200,
        200...500
    ]
    
    private let genders = ["men", "women", "unisex"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Brand Filter
                    FilterSection(title: "Brand") {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach(catalog.availableBrands, id: \.self) { brand in
                                FilterToggleButton(
                                    title: brand,
                                    isSelected: selectedBrands.contains(brand)
                                ) {
                                    if selectedBrands.contains(brand) {
                                        selectedBrands.remove(brand)
                                    } else {
                                        selectedBrands.insert(brand)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Price Range Filter
                    FilterSection(title: "Price Range") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("$\(Int(priceRange.lowerBound)) - $\(Int(priceRange.upperBound))")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.primary)
                            
                            RangeSlider(value: $priceRange, bounds: 0...500)
                                .frame(height: 30)
                        }
                    }
                    
                    // Color Filter
                    FilterSection(title: "Color") {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                            ForEach(catalog.availableColors, id: \.self) { color in
                                FilterToggleButton(
                                    title: color.capitalized,
                                    isSelected: selectedColors.contains(color)
                                ) {
                                    if selectedColors.contains(color) {
                                        selectedColors.remove(color)
                                    } else {
                                        selectedColors.insert(color)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Fit Filter
                    FilterSection(title: "Fit") {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach(catalog.availableFits, id: \.self) { fit in
                                FilterToggleButton(
                                    title: fit.capitalized,
                                    isSelected: selectedFits.contains(fit)
                                ) {
                                    if selectedFits.contains(fit) {
                                        selectedFits.remove(fit)
                                    } else {
                                        selectedFits.insert(fit)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Gender Filter
                    FilterSection(title: "Gender") {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                            ForEach(genders, id: \.self) { gender in
                                FilterToggleButton(
                                    title: gender.capitalized,
                                    isSelected: selectedGenders.contains(gender)
                                ) {
                                    if selectedGenders.contains(gender) {
                                        selectedGenders.remove(gender)
                                    } else {
                                        selectedGenders.insert(gender)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear All") {
                        clearAllFilters()
                    }
                    .foregroundStyle(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        applyFilters()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func clearAllFilters() {
        selectedBrands.removeAll()
        selectedColors.removeAll()
        selectedFits.removeAll()
        selectedGenders.removeAll()
        priceRange = 0...200
    }
    
    private func applyFilters() {
        catalog.clearAllFilters()
        
        // Apply brand filters
        for brand in selectedBrands {
            catalog.applyFilter(.brand(brand))
        }
        
        // Apply price range filter
        catalog.applyFilter(.priceRange(priceRange))
        
        // Apply color filters
        for color in selectedColors {
            catalog.applyFilter(.color(color))
        }
        
        // Apply fit filters
        for fit in selectedFits {
            catalog.applyFilter(.fit(fit))
        }
        
        // Apply gender filters
        for gender in selectedGenders {
            catalog.applyFilter(.gender(gender))
        }
    }
}

// Filter Section Component
struct FilterSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.primary)
            
            content
        }
    }
}

// Filter Toggle Button Component
struct FilterToggleButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.blue : Color.gray.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isSelected ? Color.blue : Color.gray.opacity(0.2),
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

// Simple Range Slider Component
struct RangeSlider: View {
    @Binding var value: ClosedRange<Double>
    let bounds: ClosedRange<Double>
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 4)
                    .cornerRadius(2)
                
                // Selected range
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: CGFloat((value.upperBound - value.lowerBound) / (bounds.upperBound - bounds.lowerBound)) * geometry.size.width, height: 4)
                    .offset(x: CGFloat((value.lowerBound - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)) * geometry.size.width)
                    .cornerRadius(2)
                
                // Thumbs
                Circle()
                    .fill(Color.blue)
                    .frame(width: 20, height: 20)
                    .offset(x: CGFloat((value.lowerBound - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)) * geometry.size.width - 10)
                    .gesture(DragGesture().onChanged { gesture in
                        let newValue = bounds.lowerBound + Double(gesture.location.x / geometry.size.width) * (bounds.upperBound - bounds.lowerBound)
                        value = min(newValue, value.upperBound - 10)...value.upperBound
                    })
                
                Circle()
                    .fill(Color.blue)
                    .frame(width: 20, height: 20)
                    .offset(x: CGFloat((value.upperBound - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)) * geometry.size.width - 10)
                    .gesture(DragGesture().onChanged { gesture in
                        let newValue = bounds.lowerBound + Double(gesture.location.x / geometry.size.width) * (bounds.upperBound - bounds.lowerBound)
                        value = value.lowerBound...max(newValue, value.lowerBound + 10)
                    })
            }
        }
    }
}
