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
    let price: Double

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.timeZone = TimeZone(identifier: "UTC")!
        return formatter.string(from: date)
    }

    var formattedPrice: String {
        price.formatAsCurrency(.eur)
    }
}
