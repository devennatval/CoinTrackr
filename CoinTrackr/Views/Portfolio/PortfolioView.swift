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
    @State private var showingPnLPicker = false

    var body: some View {
        NavigationStack {
            List {
                Section(footer:
                    Group {
                        if let lastFetch = viewModel.lastFetchDate {
                            Text("Last Updated: \(lastFetch.formatted(date: .abbreviated, time: .standard))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Total Value: \(viewModel.totalValue.currencyString)")
                            .font(.title3.bold())

                        Text("Unrealized PnL: \(viewModel.profitLoss.currencyString) (\(viewModel.profitLossPercent, specifier: "%.2f")%)")
                            .foregroundColor(viewModel.profitLoss >= 0 ? .green : .red)
                    }
                    .padding(.vertical, 4)
                }
                
                Section(header: coinSectionHeader) {
                    if viewModel.coins.isEmpty {
                        ContentUnavailableView("No Tokens", systemImage: "bitcoinsign.circle")
                    } else {
                        ForEach(viewModel.coins) { coin in
                            NavigationLink(destination: TransactionListView(coin: coin)) {
                                CoinRowView(coin: coin, displayMode: viewModel.pnlDisplayMode)
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
                viewModel.startAutoFetch()
                
                Task {
                    await viewModel.fetchPrices()
                }
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

    var coinSectionHeader: some View {
        HStack(spacing: 4) {
            Text("Coins")

            Spacer()

            Button {
                showingPnLPicker = true
            } label: {
                HStack(spacing: 4) {
                    Text(viewModel.displayModeLabel)
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.down")
                        .imageScale(.small)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)
        }
        .actionSheet(isPresented: $showingPnLPicker) {
            ActionSheet(title: Text("Select View"), buttons: [
                .default(Text("PnL")) { viewModel.pnlDisplayMode = .amount },
                .default(Text("% Change")) { viewModel.pnlDisplayMode = .percentage },
                .default(Text("Price")) { viewModel.pnlDisplayMode = .valueChange },
                .cancel()
            ])
        }
    }
}
