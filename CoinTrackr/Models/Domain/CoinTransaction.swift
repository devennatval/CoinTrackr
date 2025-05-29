//
//  CoinTransaction.swift
//  CoinTrackr
//
//  Created by Deven Nathanael on 28/05/25.
//

import Foundation
import SwiftData

@Model
final class CoinTransaction {
    @Attribute(.unique) var id: UUID
    var coinID: UUID
    var price: Double
    var coinAmount: Double
    var fiatAmount: Double
    var date: Date

    init(
        id: UUID = UUID(),
        coinID: UUID,
        price: Double,
        coinAmount: Double,
        fiatAmount: Double,
        date: Date = Date()
    ) {
        self.id = id
        self.coinID = coinID
        self.price = price
        self.coinAmount = coinAmount
        self.fiatAmount = fiatAmount
        self.date = date
    }
}
