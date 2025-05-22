//
//  BitcoinNetworkingProtocol.swift
//  BitcoinTracker
//
//  Created by Guilherme Giohji Hoshino on 21/05/2025.
//
import Foundation

protocol BitcoinNetworkingProtocol: Sendable {
    func fetchCurrentPrice() async throws -> SimplePriceResponse
    func fetchPriceHistory(days: Int) async throws -> MarketChartResponse
    func fetchPriceHistory(date: Date) async throws -> HistoryResponse
}
