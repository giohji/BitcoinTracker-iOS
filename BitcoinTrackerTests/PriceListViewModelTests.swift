//
//  PriceListViewModelTests.swift
//  BitcoinTrackerTests
//
//  Created by Guilherme Giohji Hoshino on 20/05/2025.
//

import XCTest
@testable import BitcoinTracker

final class PriceListViewModelTests: XCTestCase {
    var mockNetworkService: MockBitcoinNetworkService!
    var viewModel: PriceListViewModel!
    
    @MainActor
    override func setUpWithError() throws {
        mockNetworkService = MockBitcoinNetworkService()
        viewModel = PriceListViewModel(networkService: mockNetworkService)
    }
    
    @MainActor
    override func tearDownWithError() throws {
        mockNetworkService = nil
        viewModel = nil
    }
    
    // MARK: - PriceListViewModel Tests
    
    @MainActor
    func testViewModelInitialState() {
        XCTAssertEqual(viewModel.currentPriceState, .loading)
        XCTAssertEqual(viewModel.historicalPricesState, .loading)
    }
    
    @MainActor
    func testViewModelSuccessfulDataFetch() async {
        // Setup mock responses with a fixed timestamp for predictable testing using UTC calendar
        var utcCalendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = TimeZone(identifier: "UTC")!
        let yesterday = utcCalendar.date(byAdding: .day, value: -1, to: Date())!
        let timestamp = utcCalendar.startOfDay(for: yesterday) // 1 day ago in UTC
        let currentPrice = SimplePriceResponse(bitcoin: CoinPriceData(eur: 45000.0, lastUpdatedAt: Int(timestamp.timeIntervalSince1970)))
        mockNetworkService.currentPriceResponse = .success(currentPrice)
        
        let historicalData = MarketChartResponse(
            prices: [[Double(timestamp.timeIntervalSince1970 * 1000), 44000.0]], // CoinGecko API uses milliseconds
            marketCaps: nil,
            totalVolumes: nil
        )
        mockNetworkService.priceHistoryResponse = .success(historicalData)
        
        // Refresh data
        await viewModel.refreshData()
        
        // Verify current price state
        if case .loaded(let price, let lastUpdated) = viewModel.currentPriceState {
            XCTAssertEqual(price, "€45,000.00")
            
            // Create expected date format
            let expectedDate = Date(timeIntervalSince1970: TimeInterval(Int(timestamp.timeIntervalSince1970)))
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy HH:mm:ss"
            formatter.timeZone = .current
            let expectedDateString = formatter.string(from: expectedDate)
            
            XCTAssertEqual(lastUpdated, expectedDateString)
        } else {
            XCTFail("Current price state should be loaded")
        }
        
        // Verify historical prices state
        if case .loaded(let prices) = viewModel.historicalPricesState {
            XCTAssertEqual(prices.count, 1, "Should have exactly one historical price entry")
            let historicalPrice = prices[0]
            XCTAssertEqual(historicalPrice.date, timestamp, "Date should match the timestamp's start of day")
            XCTAssertEqual(historicalPrice.formattedEURPrice, "€44,000.00", "Price should match the historical data")
        } else {
            XCTFail("Historical prices state should be loaded")
        }
    }
    
    @MainActor
    func testViewModelErrorHandling() async {
        // Setup mock error responses
        mockNetworkService.currentPriceResponse = .failure(NetworkError.serverError(statusCode: 500, data: nil))
        mockNetworkService.priceHistoryResponse = .failure(NetworkError.serverError(statusCode: 500, data: nil))
        
        // Refresh data
        await viewModel.refreshData()
        
        // Verify error states
        switch viewModel.currentPriceState {
        case .error(let message):
            XCTAssertTrue(message.contains("500"))
        default:
            XCTFail("Current price state should be error")
        }
        
        switch viewModel.historicalPricesState {
        case .error(let message):
            XCTAssertTrue(message.contains("500"))
        default:
            XCTFail("Historical prices state should be error")
        }
    }
    
    @MainActor
    func testAutoRefresh() {
        viewModel.startAutoRefresh()
        XCTAssertNotNil(viewModel.timerSubscription)
        
        viewModel.stopAutoRefresh()
        XCTAssertNil(viewModel.timerSubscription)
    }
}
