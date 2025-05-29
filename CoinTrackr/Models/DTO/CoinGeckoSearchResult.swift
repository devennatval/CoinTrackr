//
//  CoinGeckoSearchResult.swift
//  CoinTrackr
//
//  Created by Deven Nathanael on 29/05/25.
//

import Foundation

struct CoinGeckoSearchResult: Decodable {
    let coins: [CoinGeckoSearchCoin]
}

struct CoinGeckoSearchCoin: Decodable, Identifiable {
    let id: String
    let name: String
    let api_symbol: String
    let symbol: String
    let market_cap_rank: Int?
    let thumb: String
    let large: String
}
