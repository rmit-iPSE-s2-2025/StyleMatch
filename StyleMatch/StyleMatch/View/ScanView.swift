import SwiftUI

struct ScanView: View {
    private let presets: [(name: String, tags: [String], icon: String)] = [
        ("Black Oversized Hoodie", ["hoodie","black","oversized","streetwear","unisex"], "hoodie"),
        ("White Relaxed Tee", ["tshirt","white","relaxed","casual","unisex"], "tshirt"),
        ("Green Summer Shirt", ["shirt","green","summer","casual"], "shirt"),
        ("Blue Denim Jacket", ["jacket","blue","denim","streetwear"], "jacket")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Choose Reference Style")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    Text("Select a style preset to find similar items")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Preset options with enhanced styling
                VStack(spacing: 16) {
                    ForEach(presets, id: \.name) { preset in
                        NavigationLink { 
                            ResultsView(refTags: Set(preset.tags.map { $0.lowercased() })) 
                        } label: {
                            HStack(spacing: 16) {
                                // Icon placeholder
                                Image(systemName: "tshirt")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 48, height: 48)
                                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(preset.name)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(.primary)
                                    
                                    Text(preset.tags.joined(separator: " • "))
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(20)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                
                // Future feature note
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Coming Soon")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.primary)
                            
                            Text("Photo scanning and AI style detection")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 20)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Reference Styles")
        .navigationBarTitleDisplayMode(.large)
    }
}

