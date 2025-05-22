//
//  BitcoinNetworkService.swift
//  BitcoinTracker
//
//  Created by Guilherme Giohji Hoshino on 21/05/2025.
//
import Foundation

/// A service class responsible for making network requests to the CoinGecko API.
/// This class implements the BitcoinNetworkingProtocol and provides methods to fetch
/// current and historical Bitcoin prices.
///
/// The service includes the following features:
/// - Automatic retry for transient failures with exponential backoff
/// - Proper error handling and mapping
/// - Support for CoinGecko API key (optional)
/// - Strong type safety through response models
///
/// Usage example:
/// ```swift
/// let service = BitcoinNetworkService()
/// do {
///     let price = try await service.fetchCurrentPrice()
///     print("Current BTC price: €\(price.bitcoin?.eur ?? 0)")
/// } catch {
///     print("Failed to fetch price: \(error)")
/// }
/// ```
final class BitcoinNetworkService: BitcoinNetworkingProtocol {
    /// The base URL for the CoinGecko API
    private let baseURL = URL(string: "https://api.coingecko.com/api/v3")!
    /// The networking session used for making HTTP requests
    private let session: NetworkFetching
    /// The request retrier for handling transient failures
    private let retrier: NetworkRequestRetrier
    
    /// Initializes the network service with custom dependencies
    /// - Parameters:
    ///   - session: A NetworkFetching instance for making HTTP requests (defaults to URLSession.shared)
    ///   - retrier: A NetworkRequestRetrier instance for handling retries (defaults to a new instance)
    init(
        session: NetworkFetching = URLSession.shared,
        retrier: NetworkRequestRetrier = NetworkRequestRetrier()
    ) {
        self.session = session
        self.retrier = retrier
    }

    // MARK: - Public API

    /// Fetches the current Bitcoin price in EUR
    /// - Returns: A SimplePriceResponse containing the current price and last update time
    /// - Throws: NetworkError if the request fails
    func fetchCurrentPrice() async throws -> SimplePriceResponse {
        guard var components = URLComponents(url: baseURL.appendingPathComponent("simple/price"), resolvingAgainstBaseURL: true) else {
            throw NetworkError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "ids", value: "bitcoin"),
            URLQueryItem(name: "vs_currencies", value: "eur"),
            URLQueryItem(name: "precision", value: "full"),
            URLQueryItem(name: "include_last_updated_at", value: "true")
        ]

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        return try await performRequest(url: url)
    }

    /// Fetches historical Bitcoin prices for a specified number of days
    /// - Parameter days: Number of historical days to fetch
    /// - Returns: A MarketChartResponse containing the historical price data
    /// - Throws: NetworkError if the request fails
    func fetchPriceHistory(days: Int) async throws -> MarketChartResponse {
        guard var components = URLComponents(url: baseURL.appendingPathComponent("coins/bitcoin/market_chart"), resolvingAgainstBaseURL: true) else {
            throw NetworkError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "vs_currency", value: "eur"),
            URLQueryItem(name: "days", value: String(days)),
            URLQueryItem(name: "interval", value: "daily")
        ]

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        return try await performRequest(url: url)
    }
    
    /// Fetches historical Bitcoin price data for a specific date
    /// - Parameter date: The date for which to fetch the price data
    /// - Returns: A HistoryResponse containing the price data for the specified date
    /// - Throws: NetworkError if the request fails
    func fetchPriceHistory(date: Date) async throws -> HistoryResponse {
        guard var components = URLComponents(url: baseURL.appendingPathComponent("coins/bitcoin/history"), resolvingAgainstBaseURL: true) else {
            throw NetworkError.invalidURL
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.timeZone = TimeZone(identifier: "UTC")
        let dateString = formatter.string(from: date)

        components.queryItems = [
            URLQueryItem(name: "date", value: dateString)
        ]

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        return try await performRequest(url: url)
    }

    // MARK: - Private Helpers

    /// Performs a network request with automatic retry logic
    /// - Parameters:
    ///   - url: The URL to request
    /// - Returns: The decoded response of type T
    /// - Throws: NetworkError if the request fails after all retry attempts
    private func performRequest<T: Codable>(url: URL) async throws -> T {
        return try await retrier.execute { [weak self] in
            guard let self = self else {
                throw NetworkError.unknownResponseType
            }
            
            var request = URLRequest(url: url)
            // Use demo API key if available
            if let apiKey = Configuration.coingeckoDemoAPIKey, !apiKey.isEmpty {
                request.setValue(apiKey, forHTTPHeaderField: "x-cg-demo-api-key")
            }
            request.setValue("application/json", forHTTPHeaderField: "accept")

            do {
                let (data, response) = try await self.session.data(for: request)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.unknownResponseType
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.serverError(statusCode: httpResponse.statusCode, data: data)
                }

                do {
                    let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                    return decodedResponse
                } catch let decodingError {
                    // Log the raw data if decoding fails, which can be helpful for debugging
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Failed to decode JSON. Raw data: \(jsonString)")
                    } else {
                        print("Failed to decode JSON and could not convert data to UTF-8 string.")
                    }
                    throw NetworkError.decodingError(decodingError)
                }
            } catch let error as NetworkError {
                throw error
            } catch let error as URLError {
                // Map URLError to appropriate NetworkError
                switch error.code {
                case .badURL, .unsupportedURL:
                    throw NetworkError.invalidURL
                case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
                    throw NetworkError.networkConnectivity(error)
                default:
                    // For other URLErrors, treat as a server error
                    throw NetworkError.serverError(statusCode: 0, data: nil)
                }
            } catch {
                // For any other unexpected errors
                throw NetworkError.serverError(statusCode: 0, data: nil)
            }
        }
    }
}
