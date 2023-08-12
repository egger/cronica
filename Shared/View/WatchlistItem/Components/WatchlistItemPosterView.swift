//
//  WatchlistItemPosterView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 20/12/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct WatchlistItemPosterView: View {
    let content: WatchlistItem
    @State private var isInWatchlist = true
    @State private var isWatched = false
    @State private var isFavorite = false
    @State private var isPin = false
    @State private var isArchive = false
    @StateObject private var settings = SettingsStore.shared
    @State private var showNote = false
    @State private var showCustomListView = false
    @Binding var showPopup: Bool
    @Binding var popupType: ActionPopupItems?
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
            .presentationDetents([.large])
#if os(macOS)
            .frame(width: 400, height: 400, alignment: .center)
#elseif os(iOS)
            .appTheme()
            .appTint()
#endif
        }
        .sheet(isPresented: $showCustomListView) {
            NavigationStack {
                ItemContentCustomListSelector(contentID: content.itemContentID,
                                              showView: $showCustomListView,
                                              title: content.itemTitle, image: content.image)
            }
            .presentationDetents([.large])
#if os(macOS)
            .frame(width: 500, height: 600, alignment: .center)
#else
            .appTheme()
            .appTint()
#endif
        }
    }
    
    private var image: some View {
        WebImage(url: content.backCompatiblePosterImage)
            .resizable()
            .placeholder {
                PosterPlaceholder(title: content.itemTitle, type: content.itemMedia)
            }
            .aspectRatio(contentMode: .fill)
            .transition(.opacity)
            .overlay {
                if isInWatchlist {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            if !settings.isCompactUI {
                                if isArchive {
                                    Image(systemName: "archivebox.fill")
                                        .imageScale(.small)
                                        .foregroundColor(.white.opacity(0.9))
                                        .padding([.vertical])
                                        .padding(.trailing, 4)
                                }
                                if isPin {
                                    Image(systemName: "pin.fill")
                                        .imageScale(.small)
                                        .foregroundColor(.white.opacity(0.9))
                                        .padding([.vertical])
                                        .padding(.trailing, 4)
                                }
                            }
                            if isFavorite {
                                Image(systemName: "suit.heart.fill")
                                    .imageScale(.small)
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding([.vertical])
                                    .padding(.trailing, 4)
                            }
                            if isWatched {
                                Image(systemName: "rectangle.badge.checkmark.fill")
                                    .imageScale(.small)
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding([.vertical])
                                    .padding(.trailing, 4)
                            }
                            Image(systemName: "square.stack.fill")
                                .imageScale(.small)
                                .foregroundColor(.white.opacity(0.9))
                                .padding([.vertical, .trailing])
                        }
                        .background {
                            if content.mediumPosterImage != nil {
                                Color.black.opacity(0.6)
                                    .mask {
                                        LinearGradient(colors:
                                                        [Color.black,
                                                         Color.black.opacity(0.924),
                                                         Color.black.opacity(0.707),
                                                         Color.black.opacity(0.383),
                                                         Color.black.opacity(0)],
                                                       startPoint: .bottom,
                                                       endPoint: .top)
                                    }
                            }
                            
                        }
                    }
                }
            }
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
                                  showCustomList: $showCustomListView,
                                  popupType: $popupType,
                                  showPopup: $showPopup)
            .task {
                isWatched = content.isWatched
                isFavorite = content.isFavorite
                isPin = content.isPin
                isArchive = content.isArchive
            }
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
        WatchlistItemPosterView(content: .example, showPopup: .constant(false), popupType: .constant(nil))
    }
}

private struct DrawingConstants {
    static let posterWidth: CGFloat = 160
    static let posterHeight: CGFloat = 240
    static let compactPosterWidth: CGFloat = 80
    static let compactPosterHeight: CGFloat = 140
    static let compactPosterRadius: CGFloat = 6
    static let posterRadius: CGFloat = 12
    static let shadowRadius: CGFloat = 2.5
}
