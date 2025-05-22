//
//  HistoricalPricesSectionView.swift
//  BitcoinTracker
//
//  Created by Guilherme Giohji Hoshino on 22/05/2025.
//
import SwiftUI


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

struct HistoricalPricesSectionView: View {
    let historicalPricesState: HistoricalPricesState
    
    var body: some View {
        Section(header: Text("Last 14 Days (Daily)").font(.headline)) {
            switch historicalPricesState {
            case .loading:
                HStack {
                    ProgressView()
                    Text("Fetching history...").padding(.leading, 5)
                }
            case .loaded(let prices):
                if prices.isEmpty {
                    Text("No historical data available.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(prices) { dailyPrice in
                        NavigationLink(destination: PriceDetailView(viewModel: PriceDetailViewModel(dailyPrice: dailyPrice))) {
                            HStack {
                                Text(dailyPrice.formattedDate)
                                    .fontWeight(.medium)
                                Spacer()
                                Text(dailyPrice.formattedPrice)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            case .error:
                Text("Failed to load historical data")
                    .foregroundColor(.red)
            }
        }
    }
}
