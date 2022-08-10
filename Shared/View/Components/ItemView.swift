//
//  ItemView.swift
//  Story
//
//  Created by Alexandre Madeira on 07/02/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ItemView: View {
    let content: WatchlistItem
    @State private var isWatched: Bool = false
    @State private var isFavorite: Bool = false
    private let context = PersistenceController.shared
    init(content: WatchlistItem) {
        self.content = content
        isWatched = content.watched
        isFavorite = content.favorite
    }
    var body: some View {
        HStack {
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
        .accessibilityElement(children: .combine)
        .contextMenu {
            Button(action: {
                updateWatched()
            }, label: {
                Label(content.isWatched ? "Remove from Watched" : "Mark as Watched",
                      systemImage: content.isWatched ? "minus.circle" : "checkmark.circle")
            })
            Button(action: {
                updateFavorite()
            }, label: {
                Label(isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                      systemImage: isFavorite ? "heart.circle.fill" : "heart.circle")
            })
            ShareLink(item: content.itemLink)
            Divider()
            Button(role: .destructive, action: {
                deleteItem(item: content)
            }, label: {
                Label("Remove", systemImage: "trash")
            })
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button(action: {
                updateWatched()
            }, label: {
                Label(content.isWatched ? "Remove from Watched" : "Mark as Watched",
                      systemImage: content.isWatched ? "minus.circle" : "checkmark.circle")
                .labelStyle(.titleAndIcon)
            })
            .controlSize(.large)
            .tint(isWatched ? .yellow : .green)
            .disabled(!content.isReleasedMovie)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button(action: {
                updateFavorite()
            }, label: {
                Label(isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                      systemImage: isFavorite ? "heart.circle.fill" : "heart.circle")
            })
            .controlSize(.large)
            .labelStyle(.titleAndIcon)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: {
                deleteItem(item: content)
            }, label: {
                Label("Remove", systemImage: "trash")
                    .labelStyle(.titleAndIcon)
            })
            .controlSize(.large)
        }
    }
    
    private func updateFavorite() {
        withAnimation {
#if os(watchOS)
#else
            HapticManager.shared.softHaptic()
#endif
            withAnimation {
                isFavorite.toggle()
            }
            context.updateMarkAs(id: content.itemId, favorite: !content.favorite)
        }
    }
    
    private func updateWatched() {
        withAnimation {
#if os(watchOS)
#else
            HapticManager.shared.softHaptic()
#endif
            withAnimation {
                isWatched.toggle()
            }
            context.updateMarkAs(id: content.itemId, watched: !content.watched)
        }
    }
    
    private func deleteItem(item: WatchlistItem) {
#if os(watchOS)
#else
            HapticManager.shared.softHaptic()
#endif
        withAnimation {
            context.delete(item)
        }
    }
}

struct ItemView_Previews: PreviewProvider {
    static var previews: some View {
        ItemView(content: WatchlistItem.example)
    }
}


private struct DrawingConstants {
    static let imageWidth: CGFloat = 70
    static let imageHeight: CGFloat = 50
    static let imageRadius: CGFloat = 4
    static let textLimit: Int = 1
}
