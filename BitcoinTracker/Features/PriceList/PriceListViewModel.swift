//
//  PriceListViewModel.swift
//  BitcoinTracker
//
//  Created by Guilherme Giohji Hoshino on 21/05/2025.
//
import SwiftUI
import Combine

@MainActor
class PriceListViewModel: ObservableObject {
    @Published var currentPriceState: CurrentPriceState = .loading
    @Published var historicalPricesState: HistoricalPricesState = .loading
    
    private var historicalPrices: [Date: DailyBitcoinPrice] = [:]
    private var lastFetchedDate: Date?

    private let networkService: BitcoinNetworkingProtocol
    private let calendar = Calendar.current
    private var timerSubscription: AnyCancellable?

    // Dependency injection for network service (allows mocking for tests)
    init(networkService: BitcoinNetworkingProtocol = BitcoinNetworkService()) {
        self.networkService = networkService
    }

    func refreshData() async {
        let today = Self.utcCalendar.startOfDay(for: Date())
        let needsHistoricalUpdate = lastFetchedDate == nil || lastFetchedDate! < today
        
        // Reset current price state as we always want fresh price
        currentPriceState = .loading
        
        // Only set historical prices to loading if we need to fetch them
        if needsHistoricalUpdate {
            historicalPricesState = .loading
        }
        
        // Always fetch current price
        async let currentPrice: () = fetchCurrentPrice()
        
        // Only fetch historical prices if needed
        async let priceHistory: () = needsHistoricalUpdate ? fetchAndProcessPriceHistory() : ()
        
        // Wait for operations to complete
        await (_, _) = (currentPrice, priceHistory)
    }
    
    func startAutoRefresh() {
        timerSubscription = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.refreshData()
                }
            }
    }
    
    func stopAutoRefresh() {
        timerSubscription?.cancel()
        timerSubscription = nil
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
        let today = Self.utcCalendar.startOfDay(for: Date())
        
        // If we have recent data and it's from today, just update the UI
        if let lastFetched = lastFetchedDate,
           lastFetched == today,
           !historicalPrices.isEmpty {
            updateHistoricalPricesState()
            return
        }
        
        do {
            // Determine how many days of data we need
            var daysToFetch = 14
            if let lastFetched = lastFetchedDate,
               let daysDiff = Self.utcCalendar.dateComponents([.day], from: lastFetched, to: today).day {
                daysToFetch = min(daysDiff + 1, 14) // +1 to include today
            }
            
            let response = try await networkService.fetchPriceHistory(days: daysToFetch)
            processDailyData(response.prices)
            lastFetchedDate = today
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

        let today = Self.utcCalendar.startOfDay(for: Date())
        
        // Process new data
        for entry in pricesData {
            guard entry.count == 2,
                  let (day, price) = createDailyPrice(timestamp: entry[0], price: entry[1]) else { continue }
            historicalPrices[day] = price
        }
        
        // Remove data older than 14 days
        let oldestAllowedDate = Self.utcCalendar.date(byAdding: .day, value: -14, to: today)!
        historicalPrices = historicalPrices.filter { $0.key >= oldestAllowedDate }
        
        updateHistoricalPricesState()
    }
    
    private func updateHistoricalPricesState() {
        let sortedPrices = historicalPrices.values.sorted { $0.date > $1.date }
        historicalPricesState = sortedPrices.isEmpty
            ? .error(message: "No valid price data found")
            : .loaded(prices: sortedPrices)
    }
    
    private func createDailyPrice(timestamp: Double, price: Double) -> (day: Date, price: DailyBitcoinPrice)? {
        let date = Date(timeIntervalSince1970: timestamp / 1000)
        let dayStart = Self.utcCalendar.startOfDay(for: date)
        guard date == dayStart else {
            return nil
        }
        return (dayStart, DailyBitcoinPrice(id: dayStart, date: date, prices: [.eur: price]))
    }
}
