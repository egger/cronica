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
    @State private var showPopup = false
    @State private var isInWatchlist = false
    @State private var canReview = true
    @State private var showNote = false
    @State private var showCustomListView = false
    @State private var popupType: ActionPopupItems?
    private let persistence = PersistenceController.shared
    var body: some View {
        NavigationLink(value: item) {
            HStack {
                WebImage(url: item.cardImageMedium)
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
                    .frame(width: DrawingConstants.imageWidth,
                           height: DrawingConstants.imageHeight)
                    .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius))
                    .shadow(radius: 2.5)
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
            }
            .itemContentContextMenu(item: item,
                                    isWatched: $isWatched,
                                    showPopup: $showPopup,
                                    isInWatchlist: $isInWatchlist,
                                    showNote: $showNote,
                                    showCustomList: $showCustomListView,
                                    popupType: $popupType)
            .task {
                isInWatchlist = persistence.isItemSaved(id: item.itemContentID)
                if isInWatchlist {
                    isWatched = persistence.isMarkedAsWatched(id: item.itemContentID)
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
                                                  title: item.itemTitle)
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
        ItemContentRowView(item: .example)
    }
}