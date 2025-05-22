//
//  BitcoinNetworkingProtocol.swift
//  BitcoinTracker
//
//  Created by Guilherme Giohji Hoshino on 21/05/2025.
//
import Foundation

/// A protocol defining the interface for Bitcoin price data fetching operations.
/// 
/// This protocol is designed to:
/// - Abstract network implementation details from the rest of the app
/// - Enable dependency injection for testing
/// - Provide a clear contract for required Bitcoin price operations
/// 
/// Key design considerations:
/// - Uses async/await for modern concurrency
/// - Returns strongly typed response models
/// - Separates different price fetching operations for flexibility
/// 
/// Implementation requirements:
/// - Must handle network errors appropriately
/// - Should implement retry logic for transient failures
/// - Must maintain thread safety
protocol BitcoinNetworkingProtocol: Sendable {
    /// Fetches the current Bitcoin price.
    /// 
    /// This method retrieves the latest Bitcoin price in EUR along with
    /// the last update timestamp.
    ///
    /// - Returns: A SimplePriceResponse containing the current price data
    /// - Throws: NetworkError if the request fails
    func fetchCurrentPrice() async throws -> SimplePriceResponse

    /// Fetches historical Bitcoin prices for a specified time range.
    /// 
    /// This method retrieves daily Bitcoin prices for the specified number
    /// of past days. The prices are returned in chronological order.
    ///
    /// - Parameter days: The number of past days to fetch prices for
    /// - Returns: A MarketChartResponse containing the historical price data
    /// - Throws: NetworkError if the request fails
    func fetchPriceHistory(days: Int) async throws -> MarketChartResponse

    /// Fetches Bitcoin prices for a specific date.
    /// 
    /// This method retrieves Bitcoin prices in multiple currencies (EUR, USD, GBP)
    /// for the specified date.
    ///
    /// - Parameter date: The date to fetch prices for
    /// - Returns: A HistoryResponse containing the price data for the specified date
    /// - Throws: NetworkError if the request fails
    func fetchPriceHistory(date: Date) async throws -> HistoryResponse
}
