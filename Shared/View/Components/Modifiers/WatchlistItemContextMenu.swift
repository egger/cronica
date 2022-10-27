////
////  WatchlistItemContextMenu.swift
////  CronicaTV
////
////  Created by Alexandre Madeira on 27/10/22.
////

import SwiftUI
import SDWebImageSwiftUI

struct WatchlistItemContextMenu: ViewModifier {
    let item: WatchlistItem
    @Binding var isWatched: Bool
    @Binding var isFavorite: Bool
    @Binding var isPin: Bool
    private let context = PersistenceController.shared
    private let notification = NotificationManager.shared
    func body(content: Content) -> some View {
#if os(watchOS)
        return content
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                watchedButton
                    .tint(item.isWatched ? .yellow : .green)
                    .disabled(item.isInProduction || item.isUpcoming)
                favoriteButton
                    .tint(item.isFavorite ? .orange : .blue)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                deleteButton
            }
#else
        return content
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                watchedButton
                    .tint(item.isWatched ? .yellow : .green)
                    .disabled(item.isInProduction || item.isUpcoming)
                favoriteButton
                    .tint(item.isFavorite ? .orange : .blue)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                deleteButton
            }
            .contextMenu {
                watchedButton
                favoriteButton
                pinButton
                ShareLink(item: item.itemLink)
                Divider()
                deleteButton
            } preview: {
                previewView
            }
#endif
    }
    
    private var previewView: some View {
#if os(watchOS)
        EmptyView()
#else
        ZStack {
            WebImage(url: item.itemImage)
                .resizable()
                .placeholder {
                    ZStack {
                        Rectangle().fill(.regularMaterial)
                        Label(item.itemTitle, systemImage: "film")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                    .frame(width: 260, height: 180)
                }
                .aspectRatio(contentMode: .fill)
                .overlay {
                    VStack {
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
                                .frame(height: 70)
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
                            HStack {
                                Text(item.itemTitle)
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                                    .padding()
                                Spacer()
                            }
                        }
                    }
                }
        }
#endif
    }
    
    private var watchedButton: some View {
        Button(action: {
            withAnimation {
                withAnimation {
                    isWatched.toggle()
                }
                context.updateMarkAs(id: item.itemId, type: item.itemMedia, watched: !item.watched)
            }
        }, label: {
            Label(item.isWatched ? "Remove from Watched" : "Mark as Watched",
                  systemImage: item.isWatched ? "minus.circle" : "checkmark.circle")
        })
    }
    
    private var favoriteButton: some View {
        Button(action: {
            withAnimation {
                withAnimation {
                    isFavorite.toggle()
                }
                context.updateMarkAs(id: item.itemId, type: item.itemMedia, favorite: !item.favorite)
            }
        }, label: {
            Label(item.isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                  systemImage: item.isFavorite ? "heart.slash.circle.fill" : "heart.circle")
        })
    }
    
    private var pinButton: some View {
        Button(action: {
            PersistenceController.shared.updatePin(items: [item.notificationID])
            isPin.toggle()
        }, label: {
            Label(isPin ? "Unpin Item" : "Pin Item",
                  systemImage: isPin ? "pin.slash.fill" : "pin.fill")
        })
    }
    
    private var deleteButton: some View {
        Button(role: .destructive, action: {
            if item.notify {
                notification.removeNotification(identifier: item.notificationID)
            }
            withAnimation {
                context.delete(item)
            }
        }, label: {
            Label("Remove", systemImage: "trash")
        })
    }
}
