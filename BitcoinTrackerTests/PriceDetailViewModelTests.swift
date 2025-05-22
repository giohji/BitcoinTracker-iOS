//
//  PriceDetailViewModelTests.swift
//  BitcoinTrackerTests
//
//  Created by Guilherme Giohji Hoshino on 22/05/2025.
//

import XCTest
@testable import BitcoinTracker

final class PriceDetailViewModelTests: XCTestCase {
    var mockNetworkService: MockBitcoinNetworkService!
    var viewModel: PriceDetailViewModel!
    var testDate: Date!
    
    @MainActor
    override func setUpWithError() throws {
        mockNetworkService = MockBitcoinNetworkService()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        testDate = calendar.startOfDay(for: Date())
        
        let dailyPrice = DailyBitcoinPrice(
            id: testDate,
            date: testDate,
            prices: [.eur: 45000.0]
        )
        viewModel = PriceDetailViewModel(dailyPrice: dailyPrice, networkService: mockNetworkService)
    }
    
    @MainActor
    override func tearDownWithError() throws {
        mockNetworkService = nil
        viewModel = nil
        testDate = nil
    }
    
    @MainActor
    func testInitialState() {
        XCTAssertEqual(viewModel.priceState, .loading)
        XCTAssertEqual(viewModel.navigationTitle, viewModel.dailyPrice.formattedDate)
        XCTAssertEqual(viewModel.dailyPrice.formattedEURPrice, "€45,000.00")
        XCTAssertNil(viewModel.dailyPrice.formattedUSDPrice)
        XCTAssertNil(viewModel.dailyPrice.formattedGBPPrice)
    }
    
    @MainActor
    func testSuccessfulPriceLoad() async {
        // Setup mock response with all currency prices
        let response = HistoryResponse(
            marketData: MarketData(
                currentPrice: CurrentPrice(
                    usd: 48000.0,
                    eur: 45000.0,
                    gbp: 42000.0
                )
            )
        )
        mockNetworkService.historicalPriceResponse = .success(response)
        
        // Load prices
        await viewModel.loadPrices()
        
        // Verify state and prices
        XCTAssertEqual(viewModel.priceState, .loaded)
        XCTAssertEqual(viewModel.dailyPrice.formattedEURPrice, "€45,000.00")
        XCTAssertEqual(viewModel.dailyPrice.formattedUSDPrice, "$48,000.00")
        XCTAssertEqual(viewModel.dailyPrice.formattedGBPPrice, "£42,000.00")
    }
    
    @MainActor
    func testPriceLoadError() async {
        // Setup mock error response
        mockNetworkService.historicalPriceResponse = .failure(
            NetworkError.serverError(statusCode: 500, data: nil)
        )
        
        // Load prices
        await viewModel.loadPrices()
        
        // Verify error state
        if case .error(let message) = viewModel.priceState {
            XCTAssertTrue(message.contains("500"), "Error message should contain status code")
        } else {
            XCTFail("Expected error state")
        }
    }
    
    @MainActor
    func testPriceLoadWithMissingData() async {
        // Setup mock response with missing market data
        let response = HistoryResponse(marketData: nil)
        mockNetworkService.historicalPriceResponse = .success(response)
        
        // Load prices
        await viewModel.loadPrices()
        
        // Verify error state
        if case .error(let message) = viewModel.priceState {
            XCTAssertEqual(message, "Price data not available")
        } else {
            XCTFail("Expected error state when market data is missing")
        }
    }
}
