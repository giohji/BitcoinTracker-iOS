//
//  PriceDetailViewModel.swift
//  BitcoinTracker
//
//  Created by Guilherme Giohji Hoshino on 21/05/2025.
//
import SwiftUI

@MainActor
class PriceDetailViewModel: ObservableObject {
    @Published var dailyPrice: DailyBitcoinPrice
    @Published var priceState: PriceDetailState = .loading
    private let networkService: BitcoinNetworkingProtocol
    
    init(dailyPrice: DailyBitcoinPrice, networkService: BitcoinNetworkingProtocol = BitcoinNetworkService()) {
        self.dailyPrice = dailyPrice
        self.networkService = networkService
    }
    
    var navigationTitle: String {
        dailyPrice.formattedDate
    }
    
    func loadPrices() async {
        do {
            let response = try await networkService.fetchPriceHistory(date: dailyPrice.date)
            if let prices = response.marketData?.currentPrice {
                // Update the dailyPrice with all available currencies
                self.dailyPrice = DailyBitcoinPrice(
                    id: dailyPrice.id,
                    date: dailyPrice.date,
                    prices: [
                        .eur: prices.eur,
                        .usd: prices.usd,
                        .gbp: prices.gbp
                    ]
                )
                priceState = .loaded
            } else {
                priceState = .error(message: "Price data not available")
            }
        } catch {
            priceState = .error(message: "Failed to load prices: \(error.localizedDescription)")
        }
    }
}

enum PriceDetailState: Equatable {
    case loading
    case loaded
    case error(message: String)
    
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
