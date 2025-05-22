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
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationView {
            List {
                CurrentPriceSectionView(currentPriceState: viewModel.currentPriceState)
                    .onAppear {
                        viewModel.startAutoRefresh()
                    }
                    .onDisappear {
                        viewModel.stopAutoRefresh()
                    }
                HistoricalPricesSectionView(historicalPricesState: viewModel.historicalPricesState)
            }
            .navigationTitle("Bitcoin Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.currentPriceState.isLoading || viewModel.historicalPricesState.isLoading {
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
            .onChange(of: scenePhase) { phase in
                switch phase {
                case .background:
                    viewModel.stopAutoRefresh()
                case .active:
                    viewModel.startAutoRefresh()
                default:
                    break
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
