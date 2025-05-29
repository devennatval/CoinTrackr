//
//  CoinRowView.swift
//  CoinTrackr
//
//  Created by Deven Nathanael on 28/05/25.
//

import SwiftUI

struct CoinRowView: View {
    let coin: Coin

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

                Text("CMP: \(coin.currentPrice.trimDecimal)")
                    .font(.subheadline)
                
            }

            Spacer()

            let pnl = coin.currentPrice - coin.averagePrice
            Text(String(format: "%+.2f", pnl))
                .foregroundColor(pnl >= 0 ? .green : .red)
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
    ))
    .padding()
}
