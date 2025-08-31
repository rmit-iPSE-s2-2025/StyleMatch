

import Foundation

struct Product: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let brand: String
    let price: Double
    let imageName: String
    let colors: [String]
    let tags: [String]
    let gender: String
}
