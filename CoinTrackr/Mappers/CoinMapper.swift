//
//  CoinMapper.swift
//  CoinTrackr
//
//  Created by Deven Nathanael on 29/05/25.
//

import Foundation

struct CoinMapper {
    static func from(_ dto: CoinGeckoSearchCoin) -> Coin {
        Coin(
            symbol: dto.symbol.uppercased(),
            name: dto.name,
            coinGeckoID: dto.api_symbol,
            iconURL: dto.large,
            averagePrice: 0,
            currentPrice: 0
        )
    }
}
