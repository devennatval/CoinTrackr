//
//  PortfolioView.swift
//  CoinTrackr
//
//  Created by Deven Nathanael on 28/05/25.
//

import SwiftUI
import SwiftData

struct PortfolioView: View {
    @Environment(\.modelContext) private var context
    @ObservedObject var viewModel: PortfolioViewModel

    @State private var toDeleteCoin: Coin?
    @State private var showAddTransaction = false
    @State private var showDeleteAlert = false
                                 
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.coins) { coin in
                    CoinRowView(coin: coin)
                    .swipeActions {
                        Button() {
                            toDeleteCoin = coin
                            showDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                    }
                }
            }
            .navigationTitle("Portfolio")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddTransaction = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                viewModel.loadCoins()
            }
        }
        .sheet(isPresented: $showAddTransaction, onDismiss: {
            viewModel.loadCoins()
        }) {
            NavigationStack {
//                AddTransactionView()
                Text("Add Transaction View")
            }
        }
        .alert("Delete Coin?", isPresented: $showDeleteAlert, presenting: toDeleteCoin) { coin in
            Button("Delete", role: .destructive) {
                viewModel.deleteCoin(coin)
            }
            Button("Cancel", role: .cancel) {}
        } message: { _ in
            Text("This will delete the coin and all its transactions.")
        }
    }
}
