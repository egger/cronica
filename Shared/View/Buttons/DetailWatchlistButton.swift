//
//  DetailWatchlistButton.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 13/08/22.
//

import SwiftUI

struct DetailWatchlistButton: View {
    @EnvironmentObject var viewModel: ItemContentViewModel
    @State private var showConfirmationPopup = false
    var body: some View {
        Button {
            if viewModel.isInWatchlist {
#if os(watchOS) || os(tvOS)
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
                  systemImage: viewModel.isInWatchlist ? "minus.circle.fill" : "plus.circle.fill")
            #if os(tvOS)
            .padding([.top, .bottom])
            .frame(minWidth: 480)
            #endif
        }
        .buttonStyle(.borderedProminent)
#if os(iOS) || os(macOS)
        .controlSize(.large)
#endif
        .disabled(viewModel.isLoading)
#if os(iOS) || os(macOS) || os(watchOS)
        .tint(viewModel.isInWatchlist ? .red : .blue)
#endif
#if os(iOS)
        .buttonBorderShape(.capsule)
        .shadow(radius: 2.5)
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
