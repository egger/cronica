//
//  WatchlistItemView.swift
//  Story
//
//  Created by Alexandre Madeira on 07/02/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct WatchlistItemView: View {
    let content: WatchlistItem
    @State private var isWatched: Bool = false
    @State private var isFavorite: Bool = false
    init(content: WatchlistItem) {
        self.content = content
    }
    var body: some View {
        NavigationLink(value: content) {
            HStack {
#if os(watchOS)
                image
#else
                image
                    .hoverEffect(.highlight)
#endif
                VStack(alignment: .leading) {
                    HStack {
                        Text(content.itemTitle)
                            .lineLimit(DrawingConstants.textLimit)
                    }
                    HStack {
                        Text(content.itemMedia.title)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
#if os(watchOS)
#else
                if isFavorite || content.favorite {
                    Spacer()
                    Image(systemName: "heart.fill")
                        .symbolRenderingMode(.multicolor)
                        .padding(.trailing)
                        .accessibilityLabel("\(content.itemTitle) is favorite.")
                }
#endif
            }
            .task {
                isWatched = content.isWatched
                isFavorite = content.isFavorite
            }
            .modifier(WatchlisItemContextMenu(item: content,
                                              isWatched: $isWatched,
                                              isFavorite: $isFavorite))
            .accessibilityElement(children: .combine)
        }
    }
    private var image: some View {
        ZStack {
            WebImage(url: content.image)
                .placeholder {
                    ZStack {
                        Color.secondary
                        Image(systemName: "film")
                    }
                    .frame(width: DrawingConstants.imageWidth,
                           height: DrawingConstants.imageHeight)
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .transition(.opacity)
                .frame(width: DrawingConstants.imageWidth,
                       height: DrawingConstants.imageHeight)
            if isWatched || content.watched {
                Color.black.opacity(0.6)
                Image(systemName: "checkmark.circle.fill").foregroundColor(.white)
            }
        }
        .frame(width: DrawingConstants.imageWidth,
               height: DrawingConstants.imageHeight)
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius))
    }
}

struct ItemView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistItemView(content: WatchlistItem.example)
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 70
    static let imageHeight: CGFloat = 50
    static let imageRadius: CGFloat = 4
    static let textLimit: Int = 1
}

private struct WatchlisItemContextMenu: ViewModifier {
    let item: WatchlistItem
    @Binding var isWatched: Bool
    @Binding var isFavorite: Bool
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
