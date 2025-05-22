//
//  PriceListView.swift
//  BitcoinTracker
//
//  Created by Guilherme Giohji Hoshino on 21/05/2025.
//
import SwiftUI

struct PriceListView: View {
    @StateObject var viewModel: PriceListViewModel
    @State private var showingErrorAlert = false

    var body: some View {
        NavigationView {
            List {
                // Section for Current Price
                Section(header: Text("Current Price (BTC/EUR)").font(.headline)) {
                    switch viewModel.currentPriceState {
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

                // Section for Historical Prices
                Section(header: Text("Last 14 Days (Daily)").font(.headline)) {
                    switch viewModel.historicalPricesState {
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
            .navigationTitle("Bitcoin Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if case .loading = viewModel.currentPriceState, case .loading = viewModel.historicalPricesState {
                        ProgressView()
                    } else {
                        Button {
                            Task {
                                await viewModel.refreshData()
                            }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
            }
            .refreshable {
                await viewModel.refreshData()
            }
            .onAppear {
                Task {
                    await viewModel.refreshData()
                }
            }
            .alert("Error", isPresented: $showingErrorAlert) {
                Button("OK") {
                    showingErrorAlert = false
                }
            } message: {
                if case .error(let message) = viewModel.currentPriceState {
                    Text(message)
                } else if case .error(let message) = viewModel.historicalPricesState {
                    Text(message)
                }
            }
            .onChange(of: viewModel.currentPriceState) { newValue in
                if case .error = newValue {
                    showingErrorAlert = true
                }
            }
            .onChange(of: viewModel.historicalPricesState) { newValue in
                if case .error = newValue {
                    showingErrorAlert = true
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
