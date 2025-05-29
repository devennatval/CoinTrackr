//
//  CoinLogic.swift
//  CoinTrackr
//
//  Created by Deven Nathanael on 29/05/25.
//

import Foundation
import SwiftData

extension Coin {
    func recalculateTotalAmountAndAveragePrice(using context: ModelContext) {
        let id = self.id
        
        let descriptor = FetchDescriptor<CoinTransaction>(
            predicate: #Predicate { $0.coinID == id }
        )
        
        if let txs = try? context.fetch(descriptor), !txs.isEmpty {
            let totalFiat = txs.reduce(0) { $0 + $1.fiatAmount }
            let totalCoin = txs.reduce(0) { $0 + $1.coinAmount }

            self.totalAmount = totalCoin
            
            if totalCoin > 0 {
                self.averagePrice = totalFiat / totalCoin
            }
        }
    }
}
