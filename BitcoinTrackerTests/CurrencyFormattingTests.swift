//
//  CurrencyFormattingTests.swift
//  BitcoinTrackerTests
//
//  Created by Guilherme Giohji Hoshino on 22/05/2025.
//

import XCTest
@testable import BitcoinTracker

final class CurrencyFormattingTests: XCTestCase {
    func testEuroFormatting_RoundsUpTo2DecimalPlaces() {
        // 45678.999 should round up to 45679.00
        let value = 45678.999
        let formatted = value.formatAsCurrency(.eur)
        XCTAssertEqual(formatted, "€45,679.00", "Value should round up and format with euro symbol")
    }
    
    func testUSDFormatting_RoundsToNearest2DecimalPlaces() {
        // 45678.965 should round to 45678.96
        let value = 45678.965
        let formatted = value.formatAsCurrency(.usd)
        XCTAssertEqual(formatted, "$45,678.96", "Value should round to nearest 2 decimal places and format with dollar symbol")
    }
    
    func testGBPFormatting_RoundsDownTo2DecimalPlaces() {
        // 45678.954 should round down to 45678.95
        let value = 45678.954
        let formatted = value.formatAsCurrency(.gbp)
        XCTAssertEqual(formatted, "£45,678.95", "Value should round down and format with pound symbol")
    }
}
