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
    @State private var isPin = false
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
                isPin = content.isPin
            }
            .accessibilityElement(children: .combine)
            .modifier(WatchlistItemContextMenu(item: content,
                                               isWatched: $isWatched,
                                               isFavorite: $isFavorite,
                                               isPin: $isPin))
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
