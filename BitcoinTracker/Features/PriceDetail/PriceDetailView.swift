//
//  PriceDetailView.swift
//  BitcoinTracker
//
//  Created by Guilherme Giohji Hoshino on 21/05/2025.
//
import SwiftUI

struct PriceDetailView: View {
    @StateObject var viewModel: PriceDetailViewModel

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
                    Text("Price (EUR):")
                        .fontWeight(.medium)
                    Spacer()
                    Text(viewModel.dailyPrice.formattedPrice)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
        }
        .navigationTitle(viewModel.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}
