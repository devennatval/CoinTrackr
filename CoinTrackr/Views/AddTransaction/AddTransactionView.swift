//
//  AddTransactionView.swift
//  CoinTrackr
//
//  Created by Deven Nathanael on 28/05/25.
//

import SwiftUI
import SwiftData
import Combine

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @StateObject var viewModel: AddTransactionViewModel
    
    @Query private var coins: [Coin]
    
    @State private var debounceTimer: AnyCancellable?
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case price, coinAmount, fiatAmount
    }
    
    var body: some View {
        Form {
            Section(header: Text("Coin")) {
                Picker("Choose Coin", selection: $viewModel.selectedCoin) {
                    Text("Input").tag(Optional<Coin>.none)
                    ForEach(coins) { coin in
                        Text(coin.symbol.uppercased()).tag(Optional(coin))
                    }
                }

                if viewModel.selectedCoin == nil {
                    TextField("Enter Coin Gecko ID (e.g. Bitcoin)", text: $viewModel.customSymbol)
                        .autocapitalization(.allCharacters)
                }
            }

            Section(header: Text("Transaction")) {
                TextField("Price per Coin", text: $viewModel.price)
                    .keyboardType(.decimalPad)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .price)
                    .onChange(of: viewModel.price) { debounceAutoCalc() }

                TextField("Coin Amount", text: $viewModel.coinAmount)
                    .keyboardType(.decimalPad)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .coinAmount)
                    .onChange(of: viewModel.coinAmount) { debounceAutoCalc() }

                TextField("Fiat Amount", text: $viewModel.fiatAmount)
                    .keyboardType(.decimalPad)
                    .submitLabel(.done)
                    .focused($focusedField, equals: .fiatAmount)
                    .onChange(of: viewModel.fiatAmount) { debounceAutoCalc() }

            }

            Section(footer: validationFooter) {
                Button("Save Transaction") {
                    viewModel.hasAttemptSave = true

                    if viewModel.canSave() {
                        viewModel.saveTransaction(availableCoins: coins)
                        dismiss()
                    }
                    
                }
                .tint(viewModel.canSave() ? Color.accentColor : Color.secondary)
            }
        }
        .navigationTitle("Add Transaction")
    }
    
    private var validationFooter: some View {
        Group {
            if viewModel.hasAttemptSave && !viewModel.canSave() {
                Text("Please fill at least the coin, price, and one amount.")
                    .font(.footnote)
                    .foregroundColor(.red)
            }
        }
    }
    
    private func debounceAutoCalc() {
        debounceTimer?.cancel()
        debounceTimer = Just(())
            .delay(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { _ in
                viewModel.autoCalculate(ignoring: focusedField)
            }
    }
}

#Preview {
    AddTransactionView(viewModel: AddTransactionViewModel(context: PersistenceController.shared.container.mainContext))
        .modelContainer(PersistenceController.shared.container)
}
