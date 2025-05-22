//
//  PriceListViewModel.swift
//  BitcoinTracker
//
//  Created by Guilherme Giohji Hoshino on 21/05/2025.
//
import SwiftUI

enum CurrentPriceState: Equatable {
    case loading
    case loaded(price: String)
    case error(message: String)
    
    var displayPrice: String {
        switch self {
        case .loading:
            return "Loading..."
        case .loaded(let price):
            return price
        case .error:
            return "Error"
        }
    }
    
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
    
    var errorMessage: String? {
        if case .error(let message) = self {
            return message
        }
        return nil
    }
}

enum HistoricalPricesState: Equatable {
    case loading
    case loaded(prices: [DailyBitcoinPrice])
    case error(message: String)
    
    var prices: [DailyBitcoinPrice] {
        switch self {
        case .loading, .error:
            return []
        case .loaded(let prices):
            return prices
        }
    }
    
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
    
    var errorMessage: String? {
        if case .error(let message) = self {
            return message
        }
        return nil
    }
}

@MainActor
class PriceListViewModel: ObservableObject {
    @Published var currentPriceState: CurrentPriceState = .loading
    @Published var historicalPricesState: HistoricalPricesState = .loading

    private let networkService: BitcoinNetworkingProtocol
    private let calendar = Calendar.current

    // Dependency injection for network service (allows mocking for tests)
    init(networkService: BitcoinNetworkingProtocol = BitcoinNetworkService()) {
        self.networkService = networkService
    }

    func refreshData() async {
        // Reset states at the start of a refresh
        currentPriceState = .loading
        historicalPricesState = .loading
        
        // Run fetches concurrently using a task group
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchCurrentPrice() }
            group.addTask { await self.fetchAndProcessPriceHistory() }
        }
    }

    private func fetchCurrentPrice() async {
        do {
            let response = try await networkService.fetchCurrentPrice()
            if let eurPrice = response.bitcoin?.eur {
                currentPriceState = .loaded(price: eurPrice.formatAsCurrency(.eur))
            } else {
                currentPriceState = .error(message: "Price data not available")
            }
        } catch {
            print("Error fetching current price: \(error.localizedDescription)")
            currentPriceState = .error(message: "Failed to load current price: \(error.localizedDescription)")
        }
    }

    private func fetchAndProcessPriceHistory() async {
        do {
            let response = try await networkService.fetchPriceHistory(days: 14)
            processDailyData(response.prices)
        } catch {
            print("Error fetching price history: \(error.localizedDescription)")
            historicalPricesState = .error(message: "Failed to load history: \(error.localizedDescription)")
        }
    }

    private static let utcCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .current
        return calendar
    }()

    private func processDailyData(_ dailyPrices: [[Double]]?) {
        guard let pricesData = dailyPrices else {
            historicalPricesState = .error(message: "No price data available")
            return
        }

        let dailyPrices = pricesData.compactMap { entry -> DailyBitcoinPrice? in
            guard entry.count == 2 else { return nil }
            return createDailyPrice(timestamp: entry[0], price: entry[1])?.price
        }
        
        historicalPricesState = dailyPrices.isEmpty 
            ? .error(message: "No valid price data found")
            : .loaded(prices: dailyPrices.sorted { $0.date > $1.date })
    }
    
    private func createDailyPrice(timestamp: Double, price: Double) -> (day: Date, price: DailyBitcoinPrice)? {
        let date = Date(timeIntervalSince1970: timestamp / 1000)
        let dayStart = Self.utcCalendar.startOfDay(for: date)
        // Only include the entry if the timestamp is the start of the day
        guard date == dayStart else {
            return nil
        }
        return (dayStart, DailyBitcoinPrice(id: dayStart, date: date, price: price))
    }
}
