//
//  MarkAsMenuView.swift
//  Story
//
//  Created by Alexandre Madeira on 17/08/22.
//

import SwiftUI

struct MarkAsMenuView: View {
    @EnvironmentObject var viewModel: ItemContentViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    var body: some View {
        Menu(content: {
            Button(action: {
                viewModel.update(markAsWatched: viewModel.isWatched)
            }, label: {
                Label(viewModel.isWatched ? "Remove from Watched" : "Mark as Watched",
                      systemImage: viewModel.isWatched ? "minus.circle" : "checkmark.circle")
            })
            .keyboardShortcut("w", modifiers: [.option])
            Button(action: {
                viewModel.update(markAsFavorite: viewModel.isFavorite)
            }, label: {
                Label(viewModel.isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                      systemImage: viewModel.isFavorite ? "heart.circle.fill" : "heart.circle")
            })
            .keyboardShortcut("f", modifiers: [.option])
        }, label: {
            if horizontalSizeClass == .compact {
                Label("Mark as", systemImage: "ellipsis")
            } else {
                Text("Mark as")
            }
        })
        .disabled(viewModel.isLoading ? true : false)
    }
}
