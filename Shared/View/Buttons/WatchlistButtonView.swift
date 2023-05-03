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
            if viewModel.isInWatchlist {
#if os(watchOS)
                if SettingsStore.shared.showRemoveConfirmation {
                    showConfirmationPopup = true
                } else {
                    update()
                }
#else
                update()
#endif       
            } else {
                HapticManager.shared.successHaptic()
                update()
            }
        } label: {
            Label(viewModel.isInWatchlist ? "Remove from watchlist": "Add to watchlist",
                  systemImage: viewModel.isInWatchlist ? "minus.square" : "plus.square")
        }
        .buttonStyle(.borderedProminent)
#if os(iOS) || os(macOS)
        .controlSize(.large)
#endif
        .disabled(viewModel.isLoading)
        .tint(viewModel.isInWatchlist ? .red : .blue)
#if os(iOS)
        .buttonBorderShape(.capsule)
#endif
        .alert("removeDialogTitle", isPresented: $showConfirmationPopup) {
            Button("confirmDialogAction") { update() }
            Button("cancelConfirmDialogAction") {  showConfirmationPopup = false }
        }
    }
    
    private func update() {
        guard let item = viewModel.content else { return }
        viewModel.updateWatchlist(with: item)
    }
}
