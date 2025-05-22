//
//  CurrencyFormattingTests.swift
//  BitcoinTrackerTests
//
//  Created by Guilherme Giohji Hoshino on 22/05/2025.
//

import XCTest
@testable import BitcoinTracker

/// Test suite for currency formatting functionality
/// These tests verify that the currency formatting handles various edge cases correctly,
/// including decimal rounding, large numbers, and zero values.
final class CurrencyFormattingTests: XCTestCase {
    
    // MARK: - Euro Formatting Tests
    
    func testEuroFormatting_RoundsUpTo2DecimalPlaces() {
        // 45678.999 should round up to 45679.00
        let value = 45678.999
        let formatted = value.formatAsCurrency(.eur)
        XCTAssertEqual(formatted, "€45,679.00", "Value should round up and format with euro symbol")
    }
    
    func testEuroFormatting_HandlesLargeNumbers() {
        // Test handling of billions
        let value = 1_234_567_890.12
        let formatted = value.formatAsCurrency(.eur)
        XCTAssertEqual(formatted, "€1,234,567,890.12", "Should properly format large numbers with correct grouping")
    }
    
    func testEuroFormatting_HandlesZero() {
        let value = 0.0
        let formatted = value.formatAsCurrency(.eur)
        XCTAssertEqual(formatted, "€0.00", "Zero should be formatted with two decimal places")
    }
    
    // MARK: - USD Formatting Tests
    
    func testUSDFormatting_RoundsToNearest2DecimalPlaces() {
        // 45678.965 should round to 45678.96
        let value = 45678.965
        let formatted = value.formatAsCurrency(.usd)
        XCTAssertEqual(formatted, "$45,678.96", "Value should round to nearest 2 decimal places and format with dollar symbol")
    }
    
    func testUSDFormatting_HandlesVerySmallNumbers() {
        // Test handling of very small numbers
        let value = 0.001
        let formatted = value.formatAsCurrency(.usd)
        XCTAssertEqual(formatted, "$0.00", "Very small numbers should round to zero cents")
    }
    
    func testUSDFormatting_HandlesNegativeNumbers() {
        let value = -1234.56
        let formatted = value.formatAsCurrency(.usd)
        XCTAssertEqual(formatted, "-$1,234.56", "Negative numbers should be properly formatted")
    }
    
    // MARK: - GBP Formatting Tests
    
    func testGBPFormatting_RoundsDownTo2DecimalPlaces() {
        // 45678.954 should round down to 45678.95
        let value = 45678.954
        let formatted = value.formatAsCurrency(.gbp)
        XCTAssertEqual(formatted, "£45,678.95", "Value should round down and format with pound symbol")
    }
    
    func testGBPFormatting_HandlesExactDecimals() {
        let value = 1234.50
        let formatted = value.formatAsCurrency(.gbp)
        XCTAssertEqual(formatted, "£1,234.50", "Should preserve trailing zeros in decimal places")
    }
    
    // MARK: - Edge Cases
    
    func testFormatting_HandlesMaximumValue() {
        // Test with a very large number close to Double's limits
        let value = 999_999_999_999.99 // Nearly a trillion
        
        // Test all currencies
        XCTAssertNoThrow(value.formatAsCurrency(.eur), "Should handle maximum values without throwing")
        XCTAssertNoThrow(value.formatAsCurrency(.usd), "Should handle maximum values without throwing")
        XCTAssertNoThrow(value.formatAsCurrency(.gbp), "Should handle maximum values without throwing")
    }
    
    func testFormatting_HandlesVeryPreciseNumbers() {
        // Test number with many decimal places
        let value = 1234.56789123456789
        
        // All currencies should round to 2 decimal places
        XCTAssertEqual(value.formatAsCurrency(.eur), "€1,234.57")
        XCTAssertEqual(value.formatAsCurrency(.usd), "$1,234.57")
        XCTAssertEqual(value.formatAsCurrency(.gbp), "£1,234.57")
    }
}
