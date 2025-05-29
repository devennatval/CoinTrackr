//
//  CoinGeckoService.swift
//  CoinTrackr
//
//  Created by Deven Nathanael on 28/05/25.
//

import Foundation

final class CoinGeckoService {
    static let shared = CoinGeckoService()

    private init() {}

    func fetchPrices(for ids: [String]) async throws -> [String: Double] {
        guard !ids.isEmpty else { return [:] }

        let joinedIDs = ids.joined(separator: ",")
        let urlString = "https://api.coingecko.com/api/v3/simple/price?ids=\(joinedIDs)&vs_currencies=usd"

        guard let url = URL(string: urlString) else {
            throw CoinGeckoError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw CoinGeckoError.invalidResponse
        }

        let decoded = try JSONDecoder().decode([String: [String: Double]].self, from: data)

        let priceMap = decoded.compactMapValues { $0["usd"] }
        return priceMap
    }
}

enum CoinGeckoError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid API URL"
        case .invalidResponse: return "Invalid response from CoinGecko"
        case .decodingFailed: return "Failed to decode price data"
        }
    }
}
