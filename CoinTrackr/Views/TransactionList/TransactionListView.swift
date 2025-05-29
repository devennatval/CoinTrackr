//
//  TransactionListView.swift
//  CoinTrackr
//
//  Created by Deven Nathanael on 28/05/25.
//

import SwiftUI
import SwiftData

struct TransactionListView: View {
    let coin: Coin
    @Query private var transactions: [CoinTransaction]
    @Environment(\.modelContext) private var context


    init(coin: Coin) {
        self.coin = coin
        let coinID = coin.id
        _transactions = Query(filter: #Predicate<CoinTransaction> { tx in
            tx.coinID == coinID
        })
    }
    
    private func deleteTransactions(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                context.delete(transactions[index])
            }
            
            try? context.save()
        }
    }

    var body: some View {
        List {
            if transactions.isEmpty {
                VStack {
                    Spacer()
                    ContentUnavailableView("No Transactions", systemImage: "tray")
                        .frame(maxWidth: .infinity)
                    Spacer()
                }
            } else {
                ForEach(transactions) { tx in
                    TransactionRowView(transaction: tx, latestPrice: coin.currentPrice)
                }
                .onDelete(perform: deleteTransactions)
            }
        }
        .navigationTitle("\(coin.symbol.uppercased()) Logs")
        .navigationBarTitleDisplayMode(.inline)
    }
}
