//
//  WatchButtonView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 13/08/22.
//

import SwiftUI

struct WatchButtonView: View {
    @EnvironmentObject var viewModel: ItemContentViewModel
    var body: some View {
        Button(action: {
            viewModel.update(markAsWatched: !viewModel.isWatched)
        }, label: {
            Label(viewModel.isWatched ? "Remove from watched" : "Mark as watched",
                  systemImage: viewModel.isWatched ? "minus.circle.fill" : "checkmark.circle.fill")
        })
        .buttonStyle(.bordered)
        .tint(viewModel.isWatched ? .yellow : .green)
        .controlSize(.large)
        .disabled(viewModel.isLoading)
    }
}
