//
//  NetworkError.swift
//  BitcoinTracker
//
//  Created by Guilherme Giohji Hoshino on 21/05/2025.
//
import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case serverError(statusCode: Int, data: Data?)
    case unknownResponseType
    case noData
    case decodingError(Error)
    case networkConnectivity(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid."
        case .serverError(let statusCode, let data):
            let messageBody = data.flatMap { String(data: $0, encoding: .utf8) } ?? "No data provided."
            return "Server error with status code \(statusCode): \(messageBody)"
        case .unknownResponseType:
            return "The server returned an unknown response type."
        case .noData:
            return "No data was received from the server."
        case .decodingError(let error):
            return "Failed to decode the response: \(error.localizedDescription)"
        case .networkConnectivity(let error):
            return "Network connectivity issue: \(error.localizedDescription)"
        }
    }
}
