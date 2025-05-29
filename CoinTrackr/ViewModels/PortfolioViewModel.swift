//
//  PortfolioViewModel.swift
//  CoinTrackr
//
//  Created by Deven Nathanael on 28/05/25.
//

import Foundation
import SwiftData
import Combine

@MainActor
class PortfolioViewModel: ObservableObject {
    private let context: ModelContext

    @Published var coins: [Coin] = []

    init(context: ModelContext) {
        self.context = context
    }

    func loadCoins() {
        do {
            coins = try context.fetch(FetchDescriptor<Coin>())
        } catch {
            print("Failed to load coins: \(error.localizedDescription)")
        }
    }
    
    func deleteCoin(_ coin: Coin) {
        context.delete(coin)
        try? context.save()
        coins.removeAll{ $0.id == coin.id }
    }
}
