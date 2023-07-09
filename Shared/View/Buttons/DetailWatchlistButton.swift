//
//  DetailWatchlistButton.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 13/08/22.
//

import SwiftUI

struct DetailWatchlistButton: View {
    @EnvironmentObject var viewModel: ItemContentViewModel
    @Binding var showCustomList: Bool
    @State private var showConfirmationPopup = false
    @StateObject private var settings = SettingsStore.shared
    var verticalStyle = false
    var body: some View {
        Button {
            if viewModel.isInWatchlist {
                if SettingsStore.shared.showRemoveConfirmation {
                    showConfirmationPopup = true
                } else {
                    update()
                }
            } else {
                HapticManager.shared.successHaptic()
                update()
            }
        } label: {
#if os(iOS)
            VStack {
                Image(systemName: viewModel.isInWatchlist ? "minus.circle.fill" : "plus.circle.fill")
                Text(viewModel.isInWatchlist ? "Remove" : "Add to watchlist")
                    .lineLimit(1)
                    .padding(.top, 2)
                    .font(.caption)
            }
            .padding(.vertical, 4)
            .frame(width: viewModel.isInWatchlist ? 60 : nil)
            .frame(minWidth: viewModel.isInWatchlist ? nil : 140)
#elseif os(macOS)
            Label(viewModel.isInWatchlist ? "Remove": "Add to watchlist",
                  systemImage: viewModel.isInWatchlist ? "minus.circle.fill" : "plus.circle.fill")
#else
            Label(viewModel.isInWatchlist ? "Remove from watchlist": "Add to watchlist",
                  systemImage: viewModel.isInWatchlist ? "minus.circle.fill" : "plus.circle.fill")
#if os(tvOS)
            .labelStyle(.iconOnly)
#endif
#endif
        }
        .buttonStyle(.borderedProminent)
#if os(macOS)
        .controlSize(.large)
#elseif os(iOS)
        .controlSize(.small)
        .shadow(radius: viewModel.isInWatchlist ? 0 : 2.5)
#endif
        .disabled(viewModel.isLoading)
#if os(iOS) || os(macOS) || os(watchOS)
        .tint(viewModel.isInWatchlist ? .red.opacity(0.95) : settings.appTheme.color)
#endif
#if os(iOS)
        .buttonBorderShape(.roundedRectangle(radius: 12))
#endif
        .alert("removeDialogTitle", isPresented: $showConfirmationPopup) {
            Button("confirmDialogAction") { update() }
            Button("cancelConfirmDialogAction") {  showConfirmationPopup = false }
        }
    }
    
    private func update() {
        guard let item = viewModel.content else { return }
        viewModel.updateWatchlist(with: item)
        if settings.openListSelectorOnAdding && viewModel.isInWatchlist {
            showCustomList.toggle()
        }
    }
}
