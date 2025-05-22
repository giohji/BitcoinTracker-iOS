//
//  NetworkFetching.swift
//  BitcoinTracker
//
//  Created by Guilherme Giohji Hoshino on 22/05/2025.
//

import Foundation

/// A protocol that abstracts network data fetching operations.
///
/// This protocol is designed to:
/// - Enable unit testing of network operations by allowing mock implementations
/// - Abstract underlying networking implementation details
/// - Ensure thread safety through Sendable conformance
///
/// The protocol is intentionally minimal to make it easy to implement while
/// still providing the essential functionality needed for network requests.
///
/// Example implementation using URLSession:
/// ```swift
/// class MockNetworkFetcher: NetworkFetching {
///     func data(for request: URLRequest) async throws -> (Data, URLResponse) {
///         // Return mock data for testing
///         return (mockData, mockResponse)
///     }
/// }
/// ```
protocol NetworkFetching: Sendable {
    /// Performs a network request and returns the response data.
    ///
    /// - Parameter request: The URLRequest to perform
    /// - Returns: A tuple containing the response data and metadata
    /// - Throws: Any error that occurs during the network operation
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

// MARK: - URLSession Conformance

extension URLSession: NetworkFetching {}
