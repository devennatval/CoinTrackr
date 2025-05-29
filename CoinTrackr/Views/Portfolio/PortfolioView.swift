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
                    NavigationLink(destination: TransactionListView(coin: coin)) {
                        CoinRowView(coin: coin)
                    }
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

                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Next fetch: \(viewModel.nextFetchIn)s")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .onAppear {
                viewModel.loadCoins()
                viewModel.startAutoFetch()
            }
        }
        .sheet(isPresented: $showAddTransaction, onDismiss: {
            viewModel.loadCoins()
        }) {
            NavigationStack {
                AddTransactionView(viewModel: AddTransactionViewModel(context: context))
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
