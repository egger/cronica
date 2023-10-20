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
                if #available(iOS 17, *) {
                    Image(systemName: viewModel.isInWatchlist ? "minus.circle.fill" : "plus.circle.fill")
                } else {
                    Image(systemName: viewModel.isInWatchlist ? "minus.circle.fill" : "plus.circle.fill")
                }
                Text(viewModel.isInWatchlist ? "Remove" : "Add")
                    .lineLimit(1)
                    .padding(.top, 2)
                    .font(.caption)
            }
            .padding(.vertical, 4)
            .frame(width: 75)
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
        .applyHoverEffect()
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
