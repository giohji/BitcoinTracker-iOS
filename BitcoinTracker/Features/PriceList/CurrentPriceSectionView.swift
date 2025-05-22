//
//  CurrentPriceSectionView.swift
//  BitcoinTracker
//
//  Created by Guilherme Giohji Hoshino on 22/05/2025.
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

struct CurrentPriceSectionView: View {
    let currentPriceState: CurrentPriceState
    
    var body: some View {
        Section(header: Text("Current Price (BTC/EUR)").font(.headline)) {
            switch currentPriceState {
            case .loading:
                HStack {
                    ProgressView()
                    Text("Fetching current price...").padding(.leading, 5)
                }
            case .loaded(let price):
                Text(price)
                    .font(.title2)
                    .fontWeight(.bold)
            case .error:
                Text("Error")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
            }
        }
    }
}
