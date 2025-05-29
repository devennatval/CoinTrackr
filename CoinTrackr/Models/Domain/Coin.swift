//
//  Coin.swift
//  CoinTrackr
//
//  Created by Deven Nathanael on 28/05/25.
//

import Foundation
import SwiftData

@Model
final class Coin {
    @Attribute(.unique) var id: UUID
    var symbol: String
    var name: String
    var coinGeckoID: String
    var iconURL: String
    var averagePrice: Double
    var currentPrice: Double
    var lastUpdated: Date

    @Relationship(deleteRule: .cascade) var transactions: [CoinTransaction] = []

    init(
        id: UUID = UUID(),
        symbol: String,
        name: String,
        coinGeckoID: String,
        iconURL: String = "",
        averagePrice: Double = 0,
        currentPrice: Double = 0,
        lastUpdated: Date = .distantPast
    ) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.coinGeckoID = coinGeckoID
        self.iconURL = iconURL
        self.averagePrice = averagePrice
        self.currentPrice = currentPrice
        self.lastUpdated = lastUpdated
    }
}
