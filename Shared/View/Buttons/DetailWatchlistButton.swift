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
                    updateWatchlist()
                }
            } else {
                HapticManager.shared.successHaptic()
                updateWatchlist()
            }
        } label: {
#if os(iOS) || os(watchOS)
            VStack {
                if #available(iOS 17, *), #available(watchOS 10, *) {
                    Image(systemName: viewModel.isInWatchlist ? "minus.circle.fill" : "plus.circle.fill")
                        .symbolEffect(viewModel.isInWatchlist ? .bounce.down : .bounce.up,
                                      value: viewModel.isInWatchlist)
                } else {
                    Image(systemName: viewModel.isInWatchlist ? "minus.circle.fill" : "plus.circle.fill")
                }
                Text(viewModel.isInWatchlist ? "Remove" : "Add")
                    .lineLimit(1)
                    .padding(.top, 2)
                    .font(.caption)
            }
#if os(iOS)
            .padding(.vertical, 4)
            .frame(width: 75)
#else
            .padding(.vertical, 2)
#endif
#elseif os(macOS)
            Label(viewModel.isInWatchlist ? "Remove": "Add",
                  systemImage: viewModel.isInWatchlist ? "minus.circle.fill" : "plus.circle.fill")
            .symbolEffect(viewModel.isInWatchlist ? .bounce.down : .bounce.up,
                          value: viewModel.isInWatchlist)
#else
            Label(viewModel.isInWatchlist ? "Remove": "Add",
                  systemImage: viewModel.isInWatchlist ? "minus.circle.fill" : "plus.circle.fill")
            .symbolEffect(viewModel.isInWatchlist ? .bounce.down : .bounce.up,
                          value: viewModel.isInWatchlist)
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
        .alert("Are You Sure?", isPresented: $showConfirmationPopup) {
            Button("Confirm") { updateWatchlist() }
            Button("Cancel") {  showConfirmationPopup = false }
        }
    }
    
    private func updateWatchlist() {
        guard let item = viewModel.content else { return }
        viewModel.updateWatchlist(with: item)
        if settings.openListSelectorOnAdding && viewModel.isInWatchlist {
            showCustomList.toggle()
        }
    }
}
