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
    @StateObject private var settings = SettingsStore.shared
    var body: some View {
        NavigationLink(value: content) {
            if settings.isCompactUI {
                compact
            } else {
                image
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(content.itemTitle))
    }
    
    private var image: some View {
        WebImage(url: content.mediumPosterImage)
            .resizable()
            .placeholder {
                PosterPlaceholder(title: content.itemTitle, type: content.itemMedia)
            }
            .aspectRatio(contentMode: .fill)
            .transition(.opacity)
            .frame(width: settings.isCompactUI ? DrawingConstants.compactPosterWidth : DrawingConstants.posterWidth,
                   height: settings.isCompactUI ? DrawingConstants.compactPosterHeight : DrawingConstants.posterHeight)
            .clipShape(RoundedRectangle(cornerRadius: settings.isCompactUI ? DrawingConstants.compactPosterRadius : DrawingConstants.posterRadius,
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
    
    private var compact: some View {
        VStack {
            image
            HStack {
                Text(content.itemTitle)
                    .lineLimit(2)
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .accessibilityHidden(true)
                Spacer()
            }
            Spacer()
        }
        .frame(maxWidth: DrawingConstants.compactPosterWidth)
    }
}

struct WatchlistItemPoster_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistItemPoster(content: .example)
    }
}

private struct DrawingConstants {
    static let posterWidth: CGFloat = 160
    static let compactPosterWidth: CGFloat = 80
    static let posterHeight: CGFloat = 240
    static let compactPosterHeight: CGFloat = 140
    static let compactPosterRadius: CGFloat = 4
#if os(macOS)
    static let posterRadius: CGFloat = 12
#else
    static let posterRadius: CGFloat = 8
#endif
    static let shadowRadius: CGFloat = 2
}
