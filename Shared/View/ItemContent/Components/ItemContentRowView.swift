//
//  ItemContentItemView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 04/05/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct ItemContentRowView: View {
    let item: ItemContent
    @State private var isWatched = false
    @State private var isFavorite = false
    @State private var isPin = false
    @State private var isArchive = false
    @Binding var showPopup: Bool
    @State private var isInWatchlist = false
    @State private var canReview = true
    @State private var showNote = false
    @State private var showCustomListView = false
    @Binding var popupType: ActionPopupItems?
    private let persistence = PersistenceController.shared
    var body: some View {
        NavigationLink(value: item) {
            HStack {
                ZStack {
                    WebImage(url: item.cardImageSmall)
                        .placeholder {
                            ZStack {
                                Rectangle().fill(.gray.gradient)
                                Image(systemName: "popcorn.fill")
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
                        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius))
                        .shadow(radius: 2.5)
                    if isWatched {
                        Color.black.opacity(0.5)
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                    }
                }
                .frame(width: DrawingConstants.imageWidth,
                       height: DrawingConstants.imageHeight)
                VStack(alignment: .leading) {
                    HStack {
                        Text(item.itemTitle)
                            .lineLimit(DrawingConstants.textLimit)
                    }
                    HStack {
                        Text(item.itemSearchDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
#if os(iOS) || os(macOS)
                Spacer()
                IconGridView(isFavorite: $isFavorite, isPin: $isPin)
                    .accessibilityHidden(true)
#endif
            }
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
            .task {
                isInWatchlist = persistence.isItemSaved(id: item.itemContentID)
                if isInWatchlist {
                    isWatched = persistence.isMarkedAsWatched(id: item.itemContentID)
                    isPin = persistence.isItemPinned(id: item.itemContentID)
                    isFavorite = persistence.isMarkedAsFavorite(id: item.itemContentID)
                    isArchive = persistence.isItemArchived(id: item.itemContentID)
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
#endif
#endif
            }
            .sheet(isPresented: $showCustomListView) {
                NavigationStack {
                    ItemContentCustomListSelector(contentID: item.itemContentID,
                                                  showView: $showCustomListView,
                                                  title: item.itemTitle,
                                                  image: item.cardImageSmall)
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
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 80
    static let imageHeight: CGFloat = 50
    static let imageRadius: CGFloat = 8
    static let textLimit: Int = 1
}

struct ItemContentItemView_Previews: PreviewProvider {
    static var previews: some View {
        ItemContentRowView(item: .example, showPopup: .constant(false), popupType: .constant(nil))
    }
}
