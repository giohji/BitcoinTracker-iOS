//
//  NetworkError.swift
//  BitcoinTracker
//
//  Created by Guilherme Giohji Hoshino on 21/05/2025.
//
import Foundation

enum NetworkError: Error, LocalizedError {
    /// The provided URL was invalid or malformed
    case invalidURL
    
    /// The server returned an error response
    /// - Parameters:
    ///   - statusCode: HTTP status code
    ///   - data: Raw response data (if any)
    case serverError(statusCode: Int, data: Data?)
    
    /// The server response was not of the expected type
    case unknownResponseType
    
    /// No data was returned in the response
    case noData
    
    /// Failed to decode the response data
    /// - Parameter error: The underlying decoding error
    case decodingError(Error)
    
    /// Network connectivity issues
    /// - Parameter error: The underlying networking error
    case networkConnectivity(Error)

    // MARK: - LocalizedError Implementation
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString(
                "The URL provided was invalid.",
                comment: "Invalid URL error message"
            )
        case .serverError(let statusCode, let data):
            let messageBody = data.flatMap { String(data: $0, encoding: .utf8) } ?? "No data provided."
            return String(
                format: NSLocalizedString(
                    "Server error with status code %d: %@",
                    comment: "Server error message format"
                ),
                statusCode,
                messageBody
            )
        case .unknownResponseType:
            return NSLocalizedString(
                "The server returned an unknown response type.",
                comment: "Unknown response type error message"
            )
        case .noData:
            return NSLocalizedString(
                "No data was received from the server.",
                comment: "No data error message"
            )
        case .decodingError(let error):
            return String(
                format: NSLocalizedString(
                    "Failed to decode the response: %@",
                    comment: "Decoding error message format"
                ),
                error.localizedDescription
            )
        case .networkConnectivity(let error):
            return String(
                format: NSLocalizedString(
                    "Network connectivity issue: %@",
                    comment: "Network connectivity error message format"
                ),
                error.localizedDescription
            )
        }
    }
    
    // MARK: - Helper Properties
    
    /// Indicates whether this error is likely transient and the request could be retried
    var isTransient: Bool {
        switch self {
        case .serverError(let statusCode, _):
            // 5xx errors are server errors that might be transient
            return statusCode >= 500
        case .networkConnectivity:
            // Network connectivity issues might be temporary
            return true
        case .noData:
            // Empty responses might be temporary
            return true
        default:
            // Other errors are likely permanent
            return false
        }
    }
}
