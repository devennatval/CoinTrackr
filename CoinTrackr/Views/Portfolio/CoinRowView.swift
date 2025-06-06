//
//  CoinRowView.swift
//  CoinTrackr
//
//  Created by Deven Nathanael on 28/05/25.
//

import SwiftUI

struct CoinRowView: View {
    @AppStorage(AppStorageKeys.isValueHidden) private var isValueHidden: Bool = false

    let coin: Coin
    let displayMode: PnLDisplayMode

    var valueChange: Double {
        coin.currentPrice - coin.averagePrice
    }

    var pnl: Double {
        valueChange * coin.totalAmount
    }

    var percentChange: Double {
        (valueChange / coin.averagePrice) * 100
    }

    var pnlText: String {
        switch displayMode {
        case .amount:
            return isValueHidden ? CommonConstant.hiddenValue : pnl.currencyString
        case .percentage:
            return String(format: "%+.2f%%", percentChange)
        case .valueChange:
            return valueChange.trimDecimal
        }
    }
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: coin.iconURL)) { image in
                image.resizable()
            } placeholder: {
                Circle().fill(Color.gray.opacity(0.3))
            }
            .frame(width: 32, height: 32)
            .clipShape(Circle())

            VStack(alignment: .leading) {
                Text(coin.symbol.uppercased())
                    .font(.headline)

                Text("Avg: \(coin.averagePrice.trimDecimal)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Cur: \(coin.currentPrice.trimDecimal)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
            }

            Spacer()

            Text(pnlText)
                .foregroundColor(valueChange >= 0 ? .green : .red)
        }
        .padding(.vertical, 4)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    CoinRowView(coin: Coin(
        symbol: "ETH",
        name: "Ethereum",
        coinGeckoID: "ethereum",
        iconURL: "https://assets.coingecko.com/coins/images/279/large/ethereum.png",
        averagePrice: 1700,
        currentPrice: 1850,
        lastUpdated: .now
    ), displayMode: .amount)
    .padding()
}
