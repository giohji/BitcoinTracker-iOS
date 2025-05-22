//
//  SimplePriceResponse.swift
//  BitcoinTracker
//
//  Created by Guilherme Giohji Hoshino on 21/05/2025.
//
import Foundation

struct SimplePriceResponse: Codable {
    let bitcoin: CoinPriceData?
}

struct CoinPriceData: Codable {
    let eur: Double?
    let lastUpdatedAt: Int?

    enum CodingKeys: String, CodingKey {
        case eur
        case lastUpdatedAt = "last_updated_at"
    }
}
