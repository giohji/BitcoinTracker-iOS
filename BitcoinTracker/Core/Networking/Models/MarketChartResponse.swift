//
//  MarketChartRangeResponse.swift
//  BitcoinTracker
//
//  Created by Guilherme Giohji Hoshino on 21/05/2025.
//
import Foundation

struct MarketChartResponse: Codable {
    let prices: [[Double]]?
    let marketCaps: [[Double]]?
    let totalVolumes: [[Double]]?

    enum CodingKeys: String, CodingKey {
        case prices
        case marketCaps = "market_caps"
        case totalVolumes = "total_volumes"
    }
}
