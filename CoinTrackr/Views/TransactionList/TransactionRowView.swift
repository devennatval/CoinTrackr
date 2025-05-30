//
//  TransactionRowView.swift
//  CoinTrackr
//
//  Created by Deven Nathanael on 28/05/25.
//

import SwiftUI

struct TransactionRowView: View {
    let transaction: CoinTransaction
    let latestPrice: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                infoRow(label: "Price", value: transaction.price.trimDecimal)
                infoRow(label: "Amount", value: transaction.coinAmount.trimDecimal)
                infoRow(label: "Fiat", value: transaction.fiatAmount.currencyString)
            }

            HStack {
                Text("PnL:")
                    .font(.subheadline)
                    .foregroundColor(.primary)

                Spacer()

                Text(pnlText)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(pnlColor)
            }

            Text(transaction.date.formatted(date: .abbreviated, time: .shortened))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
    
    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text("\(label):")
                .font(.body)
                .foregroundColor(.primary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .monospacedDigit()
        }
    }
    
    var pnl: Double {
        (latestPrice - transaction.price) * transaction.coinAmount
    }

    var pnlText: String {
        let prefix = pnl >= 0 ? "+" : ""
        return "\(prefix)\(pnl.currencyString)"
    }

    var pnlColor: Color {
        pnl > 0 ? .green : pnl < 0 ? .red : .secondary
    }
}

#Preview {
    TransactionRowView(
        transaction: CoinTransaction(
            coinID: UUID(),
            price: 10000,
            coinAmount: 0.1,
            fiatAmount: 1000,
            date: .now
        ),
        latestPrice: 11000
    )
}
