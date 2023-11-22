//
//  ItemContentPosterView.swift
//  Cronica
//
//  Created by Alexandre Madeira on 17/01/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ItemContentPosterView: View {
    let item: ItemContent
    private let context = PersistenceController.shared
    @State private var isInWatchlist = false
    @State private var isWatched = false
    @State private var isPin = false
    @State private var isFavorite = false
    @State private var isArchive = false
    @State private var showNote = false
    @State private var showCustomListView = false
    @Binding var showPopup: Bool
    @Binding var popupType: ActionPopupItems?
    @StateObject private var settings = SettingsStore.shared
    var body: some View {
        NavigationLink(value: item) {
            if settings.isCompactUI {
                compact
            } else {
                image
            }
        }
#if os(tvOS)
        .buttonStyle(.card)
        .itemContentContextMenu(item: item,
                                isWatched: $isWatched,
                                showPopup: $showPopup,
                                isInWatchlist: $isInWatchlist,
                                showNote: $showNote,
                                showCustomList: $showCustomListView,
                                popupType: $popupType,
                                isFavorite: $isFavorite,
                                isPin: $isPin,
                                isArchive: $isArchive)
#else
        .buttonStyle(.plain)
#endif
        .accessibility(label: Text(item.itemTitle))
    }
    
    private var image: some View {
        WebImage(url: item.posterImageMedium, options: .highPriority)
            .resizable()
            .placeholder {
                PosterPlaceholder(title: item.itemTitle, type: item.itemContentMedia)
            }
            .aspectRatio(contentMode: .fill)
            .overlay {
                if isInWatchlist {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
#if !os(tvOS)
                            if !settings.isCompactUI {
                                if isArchive {
                                    Image(systemName: "archivebox.fill")
                                        .imageScale(.small)
                                        .foregroundColor(.white.opacity(0.9))
                                        .padding([.vertical])
#if !os(tvOS)
                                        .padding(.trailing, 4)
#else
                                        .padding(.trailing, 2)
                                        .font(.caption)
#endif
                                }
                                if isPin {
                                    Image(systemName: "pin.fill")
                                        .imageScale(.small)
                                        .foregroundColor(.white.opacity(0.9))
                                        .padding([.vertical])
#if !os(tvOS)
                                        .padding(.trailing, 4)
#else
                                        .padding(.trailing, 2)
                                        .font(.caption)
#endif
                                }
                            }
                            if isFavorite {
                                Image(systemName: "suit.heart.fill")
                                    .imageScale(.small)
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding([.vertical])
#if !os(tvOS)
                                    .padding(.trailing, 4)
#else
                                    .padding(.trailing, 2)
                                    .font(.caption)
#endif
                            }
#endif
                            if isWatched {
                                Image(systemName: "rectangle.badge.checkmark.fill")
                                    .imageScale(.small)
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding([.vertical])
#if !os(tvOS)
                                    .padding(.trailing, 4)
#else
                                    .padding(.trailing, 2)
                                    .font(.caption)
#endif
                            }
                            Image(systemName: "square.stack.fill")
                                .imageScale(.small)
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.vertical)
#if !os(tvOS)
                                .padding(.trailing)
#else
                                .padding(.horizontal)
                                .font(.caption)
#endif
                        }
                        .background {
                            if item.posterImageMedium != nil {
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
                    .frame(width: settings.isCompactUI ? DrawingConstants.compactPosterWidth : DrawingConstants.posterWidth)
                }
            }
            .transition(.opacity)
            .frame(width: settings.isCompactUI ? DrawingConstants.compactPosterWidth : DrawingConstants.posterWidth,
                   height: settings.isCompactUI ? DrawingConstants.compactPosterHeight : DrawingConstants.posterHeight)
            .clipShape(RoundedRectangle(cornerRadius: settings.isCompactUI ? DrawingConstants.compactPosterRadius : DrawingConstants.posterRadius,
                                        style: .continuous))
            .shadow(radius: DrawingConstants.shadowRadius)
            .padding(.zero)
            .applyHoverEffect()
#if !os(tvOS)
            .itemContentContextMenu(item: item,
                                    isWatched: $isWatched,
                                    showPopup: $showPopup,
                                    isInWatchlist: $isInWatchlist,
                                    showNote: $showNote,
                                    showCustomList: $showCustomListView,
                                    popupType: $popupType,
                                    isFavorite: $isFavorite,
                                    isPin: $isPin,
                                    isArchive: $isArchive)
#endif
            .task {
                withAnimation {
                    isInWatchlist = context.isItemSaved(id: item.itemContentID)
                    if isInWatchlist {
                        isWatched = context.isMarkedAsWatched(id: item.itemContentID)
                        isPin = context.isItemPinned(id: item.itemContentID)
                        isFavorite = context.isMarkedAsFavorite(id: item.itemContentID)
                        isArchive = context.isItemArchived(id: item.itemContentID)
                    }
                }
            }
            .sheet(isPresented: $showNote) {
#if os(iOS) || os(macOS)
                NavigationStack {
                    ReviewView(id: item.itemContentID, showView: $showNote)
                }
                .presentationDetents([.large])
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
                    ItemContentCustomListSelector(contentID: item.itemContentID,
                                                  showView: $showCustomListView,
                                                  title: item.itemTitle, image: item.cardImageSmall)
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
#if os(macOS)
                .frame(width: 500, height: 600, alignment: .center)
#else
                .appTheme()
                .appTint()
#endif
            }
    }
    
    private var compact: some View {
        VStack(alignment: .leading) {
            image
            HStack {
                Text("\(item.itemTitle)\n")
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

#Preview {
    ItemContentPosterView(item: .example, showPopup: .constant(false), popupType: .constant(nil))
}

private struct DrawingConstants {
#if os(tvOS)
    static let posterWidth: CGFloat = 260
    static let posterHeight: CGFloat = 380
#else
    static let posterWidth: CGFloat = 160
    static let posterHeight: CGFloat = 240
#endif
    static let posterRadius: CGFloat = 8
    static let compactPosterWidth: CGFloat = 80
    static let compactPosterRadius: CGFloat = 4
    static let compactPosterHeight: CGFloat = 140
    static let shadowRadius: CGFloat = 2
}
