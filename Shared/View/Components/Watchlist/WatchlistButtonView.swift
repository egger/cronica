//
//  WatchlistButtonView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 13/08/22.
//

import SwiftUI

struct WatchlistButtonView: View {
    @EnvironmentObject var viewModel: ItemContentViewModel
    var body: some View {
        Button(action: {
            if let item = viewModel.content {
                viewModel.updateWatchlist(with: item)
            }
        }, label: {
            Label(viewModel.isInWatchlist ? "Remove from watchlist": "Add to watchlist",
                  systemImage: viewModel.isInWatchlist ? "minus.square" : "plus.square")
        })
        .buttonStyle(.bordered)
        .tint(viewModel.isInWatchlist ? .red : .blue)
        .controlSize(.large)
        .disabled(viewModel.isLoading)
    }
}
