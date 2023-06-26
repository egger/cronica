//
//  WatchlistItemRow.swift
//  Story
//
//  Created by Alexandre Madeira on 07/02/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct WatchlistItemRow: View {
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
            HStack {
                image
                    .applyHoverEffect()
#if os(watchOS)
                    .padding(.vertical)
#else
                    .shadow(radius: 2.5)
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
                .padding(.leading, 4)
#if os(iOS) || os(macOS)
                if isFavorite || content.favorite {
                    Spacer()
                    Image(systemName: "heart.fill")
                        .symbolRenderingMode(.multicolor)
                        .padding(.trailing)
                        .accessibilityHidden(true)
                }
#endif
            }
            .task {
                isWatched = content.isWatched
                isFavorite = content.isFavorite
                isPin = content.isPin
                isArchive = content.isArchive
            }
            .sheet(isPresented: $showNote) {
#if os(iOS) || os(macOS)
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
            .accessibilityElement(children: .combine)
            .watchlistContextMenu(item: content,
                                  isWatched: $isWatched,
                                  isFavorite: $isFavorite,
                                  isPin: $isPin,
                                  isArchive: $isArchive,
                                  showNote: $showNote,
                                  showCustomList: $showCustomListView)
        }
    }
    
    private var image: some View {
        ZStack {
            WebImage(url: content.image)
                .placeholder {
                    ZStack {
                        Rectangle().fill(.gray.gradient)
                        Image(systemName: content.itemMedia == .movie ? "film" : "tv")
                            .foregroundColor(.white.opacity(0.8))
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
                Color.black.opacity(0.5)
                Image(systemName: "checkmark.circle.fill").foregroundColor(.white)
            }
        }
        .frame(width: DrawingConstants.imageWidth,
               height: DrawingConstants.imageHeight)
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius))
    }
}

struct WatchlistItemRow_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistItemRow(content: .example)
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 80
    static let imageHeight: CGFloat = 50
    static let imageRadius: CGFloat = 8
    static let textLimit: Int = 1
}
