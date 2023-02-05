//
//  WatchlistButtonView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 13/08/22.
//

import SwiftUI

struct WatchlistButtonView: View {
    @EnvironmentObject var viewModel: ItemContentViewModel
    @State private var showConfirmationPopup = false
    var body: some View {
        Button {
#if os(watchOS)
            if viewModel.isInWatchlist {
                showConfirmationPopup = true
            } else {
                update()
            }
#else
            if !viewModel.isInWatchlist {
                HapticManager.shared.successHaptic()
            }
            update()
#endif
        } label: {
            Label(viewModel.isInWatchlist ? "Remove from watchlist": "Add to watchlist",
                  systemImage: viewModel.isInWatchlist ? "minus.square" : "plus.square")
            .fontDesign(.rounded)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(viewModel.isLoading)
        .tint(viewModel.isInWatchlist ? .red : .blue)
#if os(iOS)
        .buttonBorderShape(.capsule)
#elseif os(watchOS)
        .alert("removeDialogTitle", isPresented: $showConfirmationPopup) {
            Button("confirmDialogAction") { update() }
            Button("cancelConfirmDialogAction") {  showConfirmationPopup = false }
        }
#endif
    }
    
    private func update() {
        if let item = viewModel.content {
            viewModel.updateWatchlist(with: item)
        }
    }
}
