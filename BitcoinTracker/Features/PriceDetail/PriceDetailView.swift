//
//  PriceDetailView.swift
//  BitcoinTracker
//
//  Created by Guilherme Giohji Hoshino on 21/05/2025.
//
import SwiftUI

struct PriceDetailView: View {
    @StateObject var viewModel: PriceDetailViewModel
    @State private var showingErrorAlert = false

    var body: some View {
        List {
            Section(header: Text("Price Details").font(.headline)) {
                HStack {
                    Text("Date:")
                        .fontWeight(.medium)
                    Spacer()
                    Text(viewModel.dailyPrice.formattedDate)
                }

                HStack {
                    Text("EUR Price:")
                        .fontWeight(.medium)
                    Spacer()
                    Text(viewModel.dailyPrice.formattedEURPrice ?? "N/A")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                if viewModel.priceState.isLoading {
                    HStack {
                        ProgressView()
                        Text("Loading additional prices...").padding(.leading, 5)
                    }
                }

                if let usdPrice = viewModel.dailyPrice.formattedUSDPrice {
                    HStack {
                        Text("USD Price:")
                            .fontWeight(.medium)
                        Spacer()
                        
                        Text(usdPrice)
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }

                if let gbpPrice = viewModel.dailyPrice.formattedGBPPrice {
                    HStack {
                        Text("GBP Price:")
                            .fontWeight(.medium)
                        Spacer()
                        
                        Text(gbpPrice)
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .navigationTitle(viewModel.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadPrices()
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK") {
                showingErrorAlert = false
            }
        } message: {
            if case .error(let message) = viewModel.priceState {
                Text(message)
            }
        }
        .onChange(of: viewModel.priceState) { newValue in
            if case .error = newValue {
                showingErrorAlert = true
            }
        }
    }
}
