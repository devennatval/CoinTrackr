//
//  AddTransactionViewModel.swift
//  CoinTrackr
//
//  Created by Deven Nathanael on 29/05/25.
//

import Foundation
import SwiftData
import Combine

@MainActor
class AddTransactionViewModel: ObservableObject {
    private let context: ModelContext
    
    @Published var selectedCoin: Coin? = nil
    @Published var customSymbol: String = ""
    @Published var price: String = ""
    @Published var coinAmount: String = ""
    @Published var fiatAmount: String = ""

    @Published var hasAttemptSave = false

    init(context: ModelContext) {
        self.context = context
    }
    
    func canSave() -> Bool {
        (selectedCoin != nil || !customSymbol.isEmpty)
        && Double(price) != nil
        && Double(coinAmount) != nil
        && Double(fiatAmount) != nil
    }
    
    func autoCalculate(ignoring: AddTransactionView.Field?) {
        let priceVal = Double(price)
        let amountVal = Double(coinAmount)
        let fiatVal = Double(fiatAmount)

        guard [priceVal, amountVal, fiatVal].compactMap({ $0 }).count == 2 else {
            return
        }
        
        if ignoring != .fiatAmount, let p = priceVal, let a = amountVal {
            fiatAmount = String((p * a).trimDecimal)
        } else if ignoring != .coinAmount, let p = priceVal, let f = fiatVal {
            coinAmount = String((f / p).trimDecimal)
        } else if ignoring != .price, let a = amountVal, let f = fiatVal {
            price = String((f / a).trimDecimal)
        }
    }
    
    private func resolveCoin(from availableCoins: [Coin]) -> Coin {
        // Selected from the picker
        if let selected = selectedCoin {
            return selected
        }

        // Typed an existing coin
        if let existing = availableCoins.first(where: { $0.symbol.lowercased() == customSymbol.lowercased() }) {
            return existing
        }

        // Create new coin
        let newCoin = Coin(
            symbol: customSymbol.uppercased(),
            name: customSymbol.uppercased(),
            coinGeckoID: customSymbol.lowercased()
        )
        context.insert(newCoin)
        return newCoin
    }
    
    func saveTransaction(availableCoins: [Coin]) {
        guard let price = Double(price),
              let coinAmount = Double(coinAmount),
              let fiatAmount = Double(fiatAmount) else { return }

        let coin = resolveCoin(from: availableCoins)

        let tx = CoinTransaction(
            coinID: coin.id,
            price: price,
            coinAmount: coinAmount,
            fiatAmount: fiatAmount,
            date: Date()
        )
        
        context.insert(tx)

        coin.recalculateAveragePrice(using: context)
        try? context.save()
    }
}
