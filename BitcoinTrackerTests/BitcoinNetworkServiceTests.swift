//
//  BitcoinNetworkServiceTests.swift
//  BitcoinTrackerTests
//
//  Created by Guilherme Giohji Hoshino on 22/05/2025.
//

import XCTest
@testable import BitcoinTracker

final class BitcoinNetworkServiceTests: XCTestCase {
    
    // Mock URLSession for testing network requests
    final class MockURLSession: NetworkFetching, @unchecked Sendable {
        var mockData: Data?
        var mockResponse: URLResponse?
        var mockError: Error?
        
        func data(for request: URLRequest) async throws -> (Data, URLResponse) {
            if let error = mockError {
                throw error
            }
            
            guard let data = mockData,
                  let response = mockResponse else {
                throw NetworkError.noData
            }
            
            return (data, response)
        }
    }
    
    var mockSession: MockURLSession!
    var networkService: BitcoinNetworkService!
    
    override func setUpWithError() throws {
        mockSession = MockURLSession()
        networkService = BitcoinNetworkService(session: mockSession)
    }
    
    override func tearDownWithError() throws {
        mockSession = nil
        networkService = nil
    }
    
    // MARK: - Helper Methods
    
    private func makeSuccessResponse(statusCode: Int = 200) -> HTTPURLResponse {
        HTTPURLResponse(
            url: URL(string: "https://api.coingecko.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }
    
    // MARK: - Current Price Tests
    
    func testFetchCurrentPriceSuccess() async throws {
        // Prepare mock response
        let mockJSON = """
        {
            "bitcoin": {
                "eur": 45000.0,
                "last_updated_at": \(Int(Date().timeIntervalSince1970))
            }
        }
        """
        mockSession.mockData = mockJSON.data(using: .utf8)
        mockSession.mockResponse = makeSuccessResponse()
        
        // Test the request
        let response = try await networkService.fetchCurrentPrice()
        XCTAssertNotNil(response.bitcoin)
        XCTAssertEqual(response.bitcoin?.eur, 45000.0)
    }
    
    func testFetchCurrentPriceServerError() async {
        // Prepare mock error response
        mockSession.mockData = "Server Error".data(using: .utf8)
        mockSession.mockResponse = makeSuccessResponse(statusCode: 500)
        
        do {
            _ = try await networkService.fetchCurrentPrice()
            XCTFail("Expected server error")
        } catch let error as NetworkError {
            if case .serverError(let statusCode, _) = error {
                XCTAssertEqual(statusCode, 500)
            } else {
                XCTFail("Wrong error type")
            }
        } catch {
            XCTFail("Wrong error type")
        }
    }
    
    // MARK: - Price History Tests
    
    func testFetchPriceHistorySuccess() async throws {
        // Prepare mock response
        let mockJSON = """
        {
            "prices": [
                [\(Double(Date().timeIntervalSince1970) * 1000), 45000.0]
            ],
            "market_caps": [],
            "total_volumes": []
        }
        """
        mockSession.mockData = mockJSON.data(using: .utf8)
        mockSession.mockResponse = makeSuccessResponse()
        
        // Test the request
        let response = try await networkService.fetchPriceHistory(days: 14)
        XCTAssertNotNil(response.prices)
        XCTAssertEqual(response.prices?.count, 1)
        XCTAssertEqual(response.prices?.first?.count, 2)
        XCTAssertEqual(response.prices?.first?[1], 45000.0)
    }
    
    func testFetchHistoricalPriceSuccess() async throws {
        // Prepare mock response
        let mockJSON = """
        {
            "market_data": {
                "current_price": {
                    "usd": 45000.0,
                    "eur": 40000.0,
                    "gbp": 35000.0
                }
            }
        }
        """
        mockSession.mockData = mockJSON.data(using: .utf8)
        mockSession.mockResponse = makeSuccessResponse()
        
        // Test the request
        let response = try await networkService.fetchPriceHistory(date: Date())
        XCTAssertNotNil(response.marketData)
        XCTAssertEqual(response.marketData?.currentPrice.usd, 45000.0)
        XCTAssertEqual(response.marketData?.currentPrice.eur, 40000.0)
        XCTAssertEqual(response.marketData?.currentPrice.gbp, 35000.0)
    }
    
    func testNetworkErrorHandling() async {
        // Test different error scenarios
        let testCases: [(Error, NetworkError)] = [
            (URLError(.badURL), .invalidURL),
            (URLError(.notConnectedToInternet), NetworkError.serverError(statusCode: 0, data: nil))
        ]
        
        for (inputError, expectedError) in testCases {
            mockSession.mockError = inputError
            
            do {
                _ = try await networkService.fetchCurrentPrice()
                XCTFail("Expected error to be thrown")
            } catch {
                if let networkError = error as? NetworkError {
                    switch (networkError, expectedError) {
                    case (.invalidURL, .invalidURL):
                        // Test passed
                        break
                    case (.serverError(let code1, _), .serverError(let code2, _)) where code1 == code2:
                        // Test passed
                        break
                    default:
                        XCTFail("Unexpected error type: \(networkError). Expected: \(expectedError)")
                    }
                } else {
                    XCTFail("Expected NetworkError but got \(type(of: error))")
                }
            }
        }
    }
    
    func testInvalidJSONHandling() async {
        // Prepare invalid JSON response
        mockSession.mockData = "Invalid JSON".data(using: .utf8)
        mockSession.mockResponse = makeSuccessResponse()
        
        do {
            _ = try await networkService.fetchCurrentPrice()
            XCTFail("Expected decoding error")
        } catch let error as NetworkError {
            if case .decodingError = error {
                // Test passed
            } else {
                XCTFail("Wrong error type")
            }
        } catch {
            XCTFail("Wrong error type")
        }
    }
}
