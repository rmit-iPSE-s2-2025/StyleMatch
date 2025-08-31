//
//  Item.swift
//  StyleMatch
//
//  Created by Pranav sharma on 30/08/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
