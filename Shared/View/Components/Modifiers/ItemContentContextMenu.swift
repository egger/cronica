//
//  ItemContentContext.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 06/06/22.
//

@preconcurrency import SwiftUI

struct ItemContentContextMenu: ViewModifier, Sendable {
    let item: ItemContent
    @Binding var showConfirmation: Bool
    @Binding var isInWatchlist: Bool
    @State private var isWatched: Bool = false
    @State private var isFavorite: Bool = false
    private let context = PersistenceController.shared
    func body(content: Content) -> some View {
#if os(watchOS)
#else
        return content
            .contextMenu {
                ShareLink(item: item.itemURL)
                Button(action: {
                    withAnimation {
                        isInWatchlist.toggle()
                    }
                    updateWatchlist(with: item)
                }, label: {
                    Label(isInWatchlist ? "Remove from watchlist": "Add to watchlist",
                          systemImage: isInWatchlist ? "minus.square" : "plus.square")
                })
                if isInWatchlist {
                    watchedButton
                    favoriteButton
                }
            }
            .task {
                if isInWatchlist {
                    isWatched = context.isMarkedAsWatched(id: item.id)
                    isFavorite = context.isMarkedAsFavorite(id: item.id)
                }
            }
#endif
    }
    
    private var watchedButton: some View {
        Button(action: {
            withAnimation {
                HapticManager.shared.softHaptic()
                context.updateMarkAs(id: item.id, watched: !isWatched)
                withAnimation {
                    isWatched.toggle()
                }
            }
        }, label: {
            Label(isWatched ? "Remove from Watched" : "Mark as Watched",
                  systemImage: isWatched ? "minus.circle" : "checkmark.circle")
        })
    }
    
    private var favoriteButton: some View {
        Button(action: {
            withAnimation {
                HapticManager.shared.softHaptic()
                context.updateMarkAs(id: item.id, favorite: !isFavorite)
                withAnimation {
                    isFavorite.toggle()
                }
            }
        }, label: {
            Label(isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                  systemImage: isFavorite ? "heart.slash.circle.fill" : "heart.circle")
        })
    }
    
    private func updateWatchlist(with item: ItemContent) {
        HapticManager.shared.softHaptic()
        if !context.isItemSaved(id: item.id, type: item.itemContentMedia) {
            Task {
                let content = try? await NetworkService.shared.fetchContent(id: item.id, type: item.itemContentMedia)
                if let content {
                    withAnimation {
                        self.context.save(content)
                        showConfirmation.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                            showConfirmation = false
                        }
                    }
                }
            }
        }
    }
}
