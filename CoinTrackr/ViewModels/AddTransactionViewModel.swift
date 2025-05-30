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
    
    // MARK: - Inputs
    @Published var transactionDate: Date = Date()
    @Published var selectedCoin: Coin? {
        didSet {
            Task {
                await handleSelectedCoinChanged(from: oldValue, to: selectedCoin)
            }
        }
    }
    @Published var customSymbol: String = ""
    @Published var price: String = ""
    @Published var coinAmount: String = ""
    @Published var fiatAmount: String = ""

    // MARK: State
    @Published var hasAttemptSave = false
    @Published var searchResults: [CoinGeckoSearchCoin] = []
    @Published var isSearching = false
    @Published var searchError: String?

    private var previousSelectedCoin: Coin?

    var priceValue: Double? {
        price.localizedDouble
    }

    var coinAmountValue: Double? {
        coinAmount.localizedDouble
    }

    var fiatAmountValue: Double? {
        fiatAmount.localizedDouble
    }
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func canSave() -> Bool {
        (selectedCoin != nil || !customSymbol.isEmpty)
        && priceValue != nil
        && coinAmountValue != nil
        && fiatAmountValue != nil
    }
    
    func autoCalculate(ignoring: AddTransactionView.Field?) {
        guard [priceValue, coinAmountValue, fiatAmountValue].compactMap({ $0 }).count == 2 else {
            return
        }
        
        if ignoring != .fiatAmount, let p = priceValue, let a = coinAmountValue {
            fiatAmount = String((p * a).trimDecimal)
        } else if ignoring != .coinAmount, let p = priceValue, p != 0, let f = fiatAmountValue {
            coinAmount = String((f / p).trimDecimal)
        } else if ignoring != .price, let a = coinAmountValue, a != 0, let f = fiatAmountValue {
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
        guard let price = priceValue,
              let coinAmount = coinAmountValue,
              let fiatAmount = fiatAmountValue
        else { return }

        let coin = resolveCoin(from: availableCoins)
        
        let tx = CoinTransaction(
            coinID: coin.id,
            price: price,
            coinAmount: coinAmount,
            fiatAmount: fiatAmount,
            date: transactionDate
        )
        
        context.insert(tx)

        coin.recalculateTotalAmountAndAveragePrice(using: context)
        try? context.save()
    }
    
    func updateSelectedCoin(to newCoin: Coin?) {
        previousSelectedCoin = selectedCoin
        selectedCoin = newCoin
    }
    
    private func handleSelectedCoinChanged(from old: Coin?, to new: Coin?) async {
        guard let oldCoin = old, oldCoin != new else { return }

        let oldId = oldCoin.id
        let descriptor = FetchDescriptor<CoinTransaction>(
            predicate: #Predicate { $0.coinID == oldId }
        )

        do {
            let transactions = try context.fetch(descriptor)
            if transactions.isEmpty {
                context.delete(oldCoin)
                try? context.save()
            }
        } catch {
            print("Failed to check transactions for cleanup: \(error)")
        }
    }

    
    func searchCoin() async {
        guard !customSymbol.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isSearching = true
        searchError = nil
        defer { isSearching = false }

        do {
            searchResults = try await CoinGeckoService.shared.search(query: customSymbol)
        } catch {
            searchError = error.localizedDescription
        }
    }
    
    func selectAndInsertCoin(from dto: CoinGeckoSearchCoin) {
        let id = dto.id
        let descriptor = FetchDescriptor<Coin>(
            predicate: #Predicate { $0.coinGeckoID == id }
        )

        if let existing = try? context.fetch(descriptor).first {
            self.selectedCoin = existing
            return
        }

        let newCoin = CoinMapper.from(dto)
        context.insert(newCoin)
        try? context.save()

        self.selectedCoin = newCoin
    }
}
