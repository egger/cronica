//
//  ItemContentContext.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 06/06/22.
//

@preconcurrency import SwiftUI
import SDWebImageSwiftUI

struct ItemContentContextMenu: ViewModifier {
    let item: ItemContent
    @Binding var showConfirmation: Bool
    @Binding var isInWatchlist: Bool
    @Binding var isWatched: Bool
    @State private var isFavorite: Bool = false
    @State private var isPin: Bool = false
    private let context = PersistenceController.shared
    func body(content: Content) -> some View {
#if os(watchOS)
#else
        return content
            .contextMenu {
                if isInWatchlist {
                    shareButton
                    watchedButton
                    favoriteButton
                    pinButton
                    Divider()
                    watchlistButton
                } else {
                    shareButton
                    Divider()
                    watchlistButton
                }
#if os(tvOS)
                Button("Cancel") { }
#endif
            } preview: {
                ItemContentContextPreview(title: item.itemTitle,
                                          image: item.cardImageLarge,
                                          overview: item.itemOverview)
            }
            .task {
                if isInWatchlist {
                    isFavorite = context.isMarkedAsFavorite(id: item.id, type: item.itemContentMedia)
                    isPin = context.isItemPinned(id: item.id, type: item.itemContentMedia)
                }
            }
#endif
    }
    
    private var watchlistButton: some View {
        Button(role: isInWatchlist ? .destructive : nil) {
            updateWatchlist(with: item)
        } label: {
            Label(isInWatchlist ? "Remove from watchlist": "Add to watchlist",
                  systemImage: isInWatchlist ? "minus.square" : "plus.square")
        }
    }
    
    private var shareButton: some View {
#if os(tvOS)
        EmptyView()
#else
        ShareLink(item: item.itemURL)
#endif
    }
    
    private var watchedButton: some View {
        Button(action: {
            context.updateMarkAs(id: item.id, type: item.itemContentMedia, watched: !isWatched)
            withAnimation {
                isWatched.toggle()
            }
        }, label: {
            Label(isWatched ? "Remove from Watched" : "Mark as Watched",
                  systemImage: isWatched ? "minus.circle" : "checkmark.circle")
        })
    }
    
    private var favoriteButton: some View {
        Button(action: {
            context.updateMarkAs(id: item.id, type: item.itemContentMedia, favorite: !isFavorite)
            withAnimation {
                isFavorite.toggle()
            }
        }, label: {
            Label(isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                  systemImage: isFavorite ? "heart.slash.circle.fill" : "heart.circle")
        })
    }
    
    private var pinButton: some View {
        Button {
            context.updatePin(items: [item.itemNotificationID])
            withAnimation {
                isPin.toggle()
            }
        } label: {
            Label(isPin ? "Unpin Item" : "Pin Item",
                  systemImage: isPin ? "pin.slash" : "pin")
        }
        
    }
    
    private func updateWatchlist(with item: ItemContent) {
        if isInWatchlist {
            withAnimation {
                isInWatchlist.toggle()
            }
            let watchlistItem = try? context.fetch(for: Int64(item.id), media: item.itemContentMedia)
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

private struct ItemContentContextPreview: View {
    let title: String
    let image: URL?
    let overview: String
    var body: some View {
#if os(watchOS)
#else
        ZStack {
            WebImage(url: image)
                .resizable()
                .placeholder {
                    ZStack {
                        Rectangle().fill(.regularMaterial)
                        Label(title, systemImage: "film")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                    .frame(width: 260, height: 180)
                }
                .aspectRatio(contentMode: .fill)
                .overlay {
                    if image != nil {
                        VStack(alignment: .leading) {
                            Spacer()
                            ZStack(alignment: .bottom) {
                                Color.black.opacity(0.4)
                                    .frame(height: 70)
                                    .mask {
                                        LinearGradient(colors: [Color.black,
                                                                Color.black.opacity(0.924),
                                                                Color.black.opacity(0.707),
                                                                Color.black.opacity(0.383),
                                                                Color.black.opacity(0)],
                                                       startPoint: .bottom,
                                                       endPoint: .top)
                                    }
                                Rectangle()
                                    .fill(.ultraThinMaterial)
                                    .frame(height: 100)
                                    .mask {
                                        VStack(spacing: 0) {
                                            LinearGradient(colors: [Color.black.opacity(0),
                                                                    Color.black.opacity(0.383),
                                                                    Color.black.opacity(0.707),
                                                                    Color.black.opacity(0.924),
                                                                    Color.black],
                                                           startPoint: .top,
                                                           endPoint: .bottom)
                                            .frame(height: 70)
                                            Rectangle()
                                        }
                                    }
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(title)
                                            .font(.callout)
                                            .foregroundColor(.white)
                                            .fontWeight(.semibold)
                                            .lineLimit(1)
                                            .padding(.horizontal)
                                            .padding(.bottom, 2)
                                        Spacer()
                                    }
                                    Text(overview)
                                        .lineLimit(2)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(.horizontal)
                                        .padding(.bottom, 16)
                                }
                            }
                        }
                    }
                }
        }
#endif
    }
}
