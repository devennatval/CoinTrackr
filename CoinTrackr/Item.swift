//
//  Item.swift
//  CoinTrackr
//
//  Created by Deven Nathanael on 27/05/25.
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
