//
//  PortfolioViewModel.swift
//  CoinTrackr
//
//  Created by Deven Nathanael on 28/05/25.
//

import Foundation
import SwiftData
import Combine

enum PnLDisplayMode {
    case amount
    case percentage
    case valueChange
}

@MainActor
class PortfolioViewModel: ObservableObject {
    private let context: ModelContext

    @Published var coins: [Coin] = []
    @Published var isFetching: Bool = false
    @Published var nextFetchIn: Int = 15
    @Published var pnlDisplayMode: PnLDisplayMode = .amount
    
    @Published var lastFetchDate: Date?
    
    private var timer: AnyCancellable?

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

    func fetchPrices() async {
        isFetching = true
        defer { isFetching = false }

        do {
            let priceMap = try await CoinGeckoService.shared.fetchPrices(for: coins.map { $0.coinGeckoID })
            for coin in coins {
                if let price = priceMap[coin.coinGeckoID] {
                    coin.currentPrice = price
                    coin.lastUpdated = Date()
                }
            }
            try context.save()
            self.lastFetchDate = Date()
        } catch {
            print("Price fetch error: \(error)")
        }
    }

    func startAutoFetch() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }

                if self.nextFetchIn > 0 {
                    self.nextFetchIn -= 1
                } else {
                    Task { await self.fetchPrices() }
                    self.nextFetchIn = 15
                }
            }
    }
    
    var totalValue: Double {
        coins.reduce(into: 0.0) { result, coin in
            result += (coin.totalAmount * coin.currentPrice)
        }
    }

    var totalCost: Double {
        coins.reduce(into: 0.0) { result, coin in
            result += (coin.totalAmount * coin.averagePrice)
        }
    }

    var profitLoss: Double {
        totalValue - totalCost
    }

    var profitLossPercent: Double {
        guard totalCost > 0 else { return 0 }
        return (profitLoss / totalCost) * 100
    }
    
    var displayModeLabel: String {
        switch(pnlDisplayMode) {
        case .amount:
            "PnL"
        case .percentage:
            "% Change"
        case .valueChange:
            "Price"
        }
    }
}
