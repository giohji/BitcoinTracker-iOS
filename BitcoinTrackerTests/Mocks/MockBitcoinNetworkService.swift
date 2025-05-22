//
//  MockBitcoinNetworkService.swift
//  BitcoinTracker
//
//  Created by Guilherme Giohji Hoshino on 22/05/2025.
//
import Foundation
@testable import BitcoinTracker

final class MockBitcoinNetworkService: BitcoinNetworkingProtocol, @unchecked Sendable {
    var currentPriceResponse: Result<SimplePriceResponse, Error> = .failure(NetworkError.noData)
    var priceHistoryResponse: Result<MarketChartResponse, Error> = .failure(NetworkError.noData)
    var historicalPriceResponse: Result<HistoryResponse, Error> = .failure(NetworkError.noData)
    
    func fetchCurrentPrice() async throws -> SimplePriceResponse {
        try currentPriceResponse.get()
    }
    
    func fetchPriceHistory(days: Int) async throws -> MarketChartResponse {
        try priceHistoryResponse.get()
    }
    
    func fetchPriceHistory(date: Date) async throws -> HistoryResponse {
        try historicalPriceResponse.get()
    }
}
