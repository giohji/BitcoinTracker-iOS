//
//  DailyBitcoinPrice.swift
//  BitcoinTracker
//
//  Created by Guilherme Giohji Hoshino on 21/05/2025.
//
import Foundation

struct DailyBitcoinPrice: Identifiable, Hashable {
    let id: Date
    let date: Date
    let prices: [Currency: Double]

    init(id: Date, date: Date, eurPrice: Double) {
        self.id = id
        self.date = date
        self.prices = [.eur: eurPrice]
    }

    init(id: Date, date: Date, prices: [Currency: Double]) {
        self.id = id
        self.date = date
        self.prices = prices
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.timeZone = TimeZone(identifier: "UTC")!
        return formatter.string(from: date)
    }

    func formattedPrice(_ currency: Currency) -> String? {
        guard let price = prices[currency] else {
            return nil
        }
        return price.formatAsCurrency(currency)
    }
    
    var formattedEURPrice: String? {
        formattedPrice(.eur)
    }

    var formattedUSDPrice: String? {
        formattedPrice(.usd)
    }

    var formattedGBPPrice: String? {
        formattedPrice(.gbp)
    }
}
