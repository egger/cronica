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
                viewModel.updateMarkAs(markAsWatched: !viewModel.isWatched)
            }, label: {
                Label(viewModel.isWatched ? "Remove from Watched" : "Mark as Watched",
                      systemImage: viewModel.isWatched ? "minus.circle" : "checkmark.circle")
            })
            .keyboardShortcut("w", modifiers: [.option])
            Button(action: {
                viewModel.updateMarkAs(markAsFavorite: !viewModel.isFavorite)
            }, label: {
                Label(viewModel.isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                      systemImage: viewModel.isFavorite ? "heart.circle.fill" : "heart.circle")
            })
            .keyboardShortcut("f", modifiers: [.option])
            Menu {
                if viewModel.content?.hasIMDbUrl ?? false {
                    Button("IMDb") {
                        if let url = viewModel.content?.imdbUrl {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                Button("TMDb") {
                    if let url = viewModel.content?.itemURL {
                        UIApplication.shared.open(url)
                    }
                }
            } label: {
                Text("Open in")
            }
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
