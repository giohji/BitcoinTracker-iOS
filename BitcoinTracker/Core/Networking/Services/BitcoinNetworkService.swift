//
//  BitcoinNetworkService.swift
//  BitcoinTracker
//
//  Created by Guilherme Giohji Hoshino on 21/05/2025.
//
import Foundation

final class BitcoinNetworkService: BitcoinNetworkingProtocol {

    private let baseURL = URL(string: "https://api.coingecko.com/api/v3")!
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: - Fetch Current Bitcoin Price
    func fetchCurrentPrice() async throws -> SimplePriceResponse {
        guard var components = URLComponents(url: baseURL.appendingPathComponent("simple/price"), resolvingAgainstBaseURL: true) else {
            throw NetworkError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "ids", value: "bitcoin"),
            URLQueryItem(name: "vs_currencies", value: "eur")
        ]

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        return try await performRequest(url: url)
    }

    // MARK: - Fetch Historical Bitcoin Prices
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
    
    // MARK: - Fetch Historical Bitcoin Price for a given date in all currencies
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

    // MARK: - Generic Request Handler with async/await
    private func performRequest<T: Codable>(url: URL) async throws -> T {
        var request = URLRequest(url: url)
        // Use demo API key if available, if Keys.xcconfig is removed from project the API is still accessible through public keyless API for now.
        if let apiKey = Configuration.coingeckoDemoAPIKey {
            request.setValue(apiKey, forHTTPHeaderField: "x-cg-demo-api-key")
        }
        request.setValue("application/json", forHTTPHeaderField: "accept")

        let (data, response) = try await session.data(for: request)

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
    }
}
