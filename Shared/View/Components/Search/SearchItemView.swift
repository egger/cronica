//
//  SearchItemView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 30/05/22.
//

import SwiftUI

struct SearchItemView: View {
    let item: ItemContent
    @Binding var showConfirmation: Bool
    @State private var isInWatchlist = false
    private let context = PersistenceController.shared
    var isSidebar = false
    var body: some View {
        if item.media == .person {
            if isSidebar {
                SearchItem(item: item, isInWatchlist: $isInWatchlist)
                    .draggable(item)
                    .contextMenu {
                        ShareLink(item: item.itemSearchURL)
                    }
            } else {
                NavigationLink(value: item) {
                    SearchItem(item: item, isInWatchlist: $isInWatchlist)
                        .draggable(item)
                        .contextMenu {
                            ShareLink(item: item.itemSearchURL)
                        }
                }
            }
        } else {
            if isSidebar {
                SearchItem(item: item, isInWatchlist: $isInWatchlist)
                    .draggable(item)
                    .task {
                        isInWatchlist = context.isItemSaved(id: item.id, type: item.itemContentMedia)
                    }
                    .modifier(ItemContentContextMenu(item: item, showConfirmation: $showConfirmation, isInWatchlist: $isInWatchlist))
            } else {
                NavigationLink(value: item) {
                    SearchItem(item: item, isInWatchlist: $isInWatchlist)
                        .draggable(item)
                        .task {
                            isInWatchlist = context.isItemSaved(id: item.id, type: item.itemContentMedia)
                        }
                        .modifier(ItemContentContextMenu(item: item, showConfirmation: $showConfirmation, isInWatchlist: $isInWatchlist))
                        .modifier(SearchItemSwipeGesture(item: item, showConfirmation: $showConfirmation, isInWatchlist: $isInWatchlist))
                }
            }
            
        }
    }
}

struct SearchItemView_Previews: PreviewProvider {
    @State private static var show: Bool = false
    static var previews: some View {
        SearchItemView(item: ItemContent.previewContent, showConfirmation: $show)
    }
}


struct SearchItemSwipeGesture: ViewModifier {
    let item: ItemContent
    @Binding var showConfirmation: Bool
    @Binding var isInWatchlist: Bool
    @State private var isWatched: Bool = false
    @State private var isFavorite: Bool = false
    private let context = PersistenceController.shared
    func body(content: Content) -> some View {
        return content
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                if isInWatchlist {
                    watchedButton
                    favoriteButton
                } else {
                    Button(action: {
                        updateWatchlist(with: item)
                    }, label: {
                        Label("Add to watchlist", systemImage: "plus.square")
                    })
                    .tint(.blue)
                }
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                if isInWatchlist {
                    Button(role: .destructive, action: {
                        updateWatchlist(with: item)
                    }, label: {
                        Label("Remove from watchlist", systemImage: "minus.square")
                    })
                }
            }
    }
    
    private var watchedButton: some View {
        Button(action: {
            context.updateMarkAs(id: item.id, watched: !isWatched)
            withAnimation {
                isWatched.toggle()
            }
        }, label: {
            Label(isWatched ? "Remove from Watched" : "Mark as Watched",
                  systemImage: isWatched ? "minus.circle" : "checkmark.circle")
        })
        .tint(isWatched ? .yellow : .green)
    }
    
    private var favoriteButton: some View {
        Button(action: {
            context.updateMarkAs(id: item.id, favorite: !isFavorite)
            withAnimation {
                isFavorite.toggle()
            }
        }, label: {
            Label(isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                  systemImage: isFavorite ? "heart.slash.circle.fill" : "heart.circle")
        })
        .tint(isFavorite ? .orange : .blue)
    }
    
    private func updateWatchlist(with item: ItemContent) {
        if isInWatchlist {
            withAnimation {
                isInWatchlist.toggle()
            }
            let watchlistItem = try? context.fetch(for: Int64(item.id))
            if let watchlistItem {
                if watchlistItem.notify {
                    NotificationManager.shared.removeNotification(identifier: watchlistItem.notificationID)
                }
                context.delete(watchlistItem)
            }
        } else {
            Task {
                let content = try? await NetworkService.shared.fetchItem(id: item.id, type: item.itemContentMedia)
                if let content {
                    context.save(content)
                    if content.itemCanNotify {
                        NotificationManager.shared.schedule(notificationContent: content)
                    }
                } else {
                    context.save(item)
                    if item.itemCanNotify {
                        NotificationManager.shared.schedule(notificationContent: item)
                    }
                }
            }
            withAnimation {
                showConfirmation.toggle()
                isInWatchlist.toggle()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                withAnimation {
                    showConfirmation = false
                }
            }
        }
    }
}
