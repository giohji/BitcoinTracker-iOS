# Bitcoin Tracker

A simple iOS app that tracks Bitcoin prices in EUR, with historical data for the last 14 days.

## Features

- Real-time Bitcoin price in EUR
- Historical price data for the last 14 days
- Detailed view for each day with prices in EUR, USD, and GBP
- Automatic price updates every 60 seconds

## Getting Started

### Prerequisites

- Xcode 15.0 or later
- iOS 15.0 or later

### Installation

1. Clone the repository
```bash
git clone https://github.com/giohji/BitcoinTracker.git
cd BitcoinTracker
```

2. Choose one of the following options:

#### Option 1: Use the public API (no API key required)
Delete the reference to `Keys.xcconfig` in the Xcode project:
- Open the project in Xcode
- Remove the reference to `Keys.xcconfig` from the project navigator

#### Option 2: Use your own API key
1. Copy the example configuration file:
```bash
cp BitcoinTracker/Configs/Keys.xcconfig.example BitcoinTracker/Configs/Keys.xcconfig
```

2. Edit `Keys.xcconfig` and replace `YOUR_COINGECKO_DEMO_API_KEY` with your actual CoinGecko API key

3. Build and run the project in Xcode

Note: The app will work with either option since CoinGecko's API is still accessible without an API key, though rate limits may apply.

## Built With

- SwiftUI - The UI framework used
- Combine - For reactive programming
- CoinGecko API - For Bitcoin price data
