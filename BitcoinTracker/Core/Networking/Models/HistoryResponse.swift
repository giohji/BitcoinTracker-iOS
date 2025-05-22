//
//  HistoryResponse.swift
//  BitcoinTracker
//
//  Created by Guilherme Giohji Hoshino on 22/05/2025.
//
import Foundation

struct HistoryResponse: Codable {
    let marketData: MarketData?
    
    enum CodingKeys: String, CodingKey {
        case marketData = "market_data"
    }
}

struct MarketData: Codable {
    let currentPrice: CurrentPrice

    enum CodingKeys: String, CodingKey {
        case currentPrice = "current_price"
    }
}

struct CurrentPrice: Codable {
    let usd: Double
    let eur: Double
    let gbp: Double
}
