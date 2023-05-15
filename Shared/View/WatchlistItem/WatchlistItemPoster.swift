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
    @State private var showNote = false
    @State private var showCustomListView = false
    var body: some View {
        NavigationLink(value: content) {
            if settings.isCompactUI {
                compact
            } else {
                image
            }
        }
        #if os(tvOS)
        .buttonStyle(.card)
        #else
        .buttonStyle(.plain)
        #endif
        .accessibilityLabel(Text(content.itemTitle))
        .sheet(isPresented: $showNote) {
            NavigationStack {
                ReviewView(id: content.itemContentID, showView: $showNote)
            }
            .presentationDetents([.medium, .large])
#if os(macOS)
            .frame(width: 400, height: 400, alignment: .center)
#elseif os(iOS)
                .appTheme()
                .appTint()
#endif
        }
        .sheet(isPresented: $showCustomListView) {
            NavigationStack {
                ItemContentCustomListSelector(contentID: content.itemContentID, showView: $showCustomListView, title: content.itemTitle)
            }
            .presentationDetents([.medium, .large])
#if os(macOS)
            .frame(width: 500, height: 600, alignment: .center)
#else
            .appTheme()
            .appTint()
#endif
        }
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
                                  isArchive: $isArchive,
                                  showNote: $showNote,
                                  showCustomList: $showCustomListView)
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
#if os(iOS) || os(macOS)
    static let posterWidth: CGFloat = 160
    static let posterHeight: CGFloat = 240
#endif
    static let compactPosterWidth: CGFloat = 80
    static let compactPosterHeight: CGFloat = 140
    static let compactPosterRadius: CGFloat = 4
#if os(macOS)
    static let posterRadius: CGFloat = 12
#elseif os(tvOS)
    static let posterWidth: CGFloat = 260
    static let posterHeight: CGFloat = 380
    static let posterRadius: CGFloat = 12
#else
    static let posterRadius: CGFloat = 8
#endif
    static let shadowRadius: CGFloat = 2
}
