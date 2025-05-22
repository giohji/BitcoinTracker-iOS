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

    init(dailyPrice: DailyBitcoinPrice) {
        self.dailyPrice = dailyPrice
    }

    var navigationTitle: String {
        dailyPrice.formattedDate
    }
}
