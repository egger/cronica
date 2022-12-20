//
//  WatchlistItemPoster.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 20/12/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct WatchlistItemPoster: View {
    let content: WatchlistItem
    @State private var isWatched: Bool = false
    @State private var isFavorite: Bool = false
    @State private var isPin = false
    @State private var isArchive = false
    var body: some View {
        NavigationLink(value: content) {
            WebImage(url: content.mediumPosterImage)
                .resizable()
                .placeholder {
                    PosterPlaceholder(title: content.itemTitle, type: content.itemMedia)
                }
                .aspectRatio(contentMode: .fill)
                .transition(.opacity)
                .frame(width: DrawingConstants.posterWidth,
                       height: DrawingConstants.posterHeight)
                .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.posterRadius,
                                            style: .continuous))
                .shadow(radius: DrawingConstants.shadowRadius)
                .padding(.zero)
                .applyHoverEffect()
                .watchlistContextMenu(item: content,
                                      isWatched: $isWatched,
                                      isFavorite: $isFavorite,
                                      isPin: $isPin,
                                      isArchive: $isArchive)
                .task {
                    isWatched = content.isWatched
                    isFavorite = content.isFavorite
                    isPin = content.isPin
                    isArchive = content.isArchive
                }
#if os(iOS) || os(macOS)
                .draggable(content)
#endif
        }
    }
}

struct WatchlistItemPoster_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistItemPoster(content: .example)
    }
}

private struct DrawingConstants {
    static let posterWidth: CGFloat = 160
    static let posterHeight: CGFloat = 240
    static let posterRadius: CGFloat = 8
    static let shadowRadius: CGFloat = 2
}
