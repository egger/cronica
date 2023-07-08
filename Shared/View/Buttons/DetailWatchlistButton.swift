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
            if UIDevice.isIPhone {
                if viewModel.isInWatchlist {
                    VStack {
                        Image(systemName: "minus.circle.fill")
                        Text("Remove")
                            .padding(.top, 2)
                            .font(.caption)
                    }
                    .padding(.vertical, 4)
                    .frame(width: 50)
                } else {
                    Label("Add to watchlist", systemImage: "plus.circle.fill")
                }
            } else {
                Label(viewModel.isInWatchlist ? "Remove from watchlist": "Add to watchlist",
                      systemImage: viewModel.isInWatchlist ? "minus.circle.fill" : "plus.circle.fill")
            }
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
        .controlSize(UIDevice.isIPhone ? viewModel.isInWatchlist ? .small: .large : .large)
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
        if settings.openListSelectorOnAdding {
            showCustomList.toggle()
        }
    }
}
