//
//  ItemContentFrameView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 07/06/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ItemContentCardView: View {
    let item: ItemContent
    @Binding var showPopup: Bool
    @Binding var popupType: ActionPopupItems?
    private let context = PersistenceController.shared
    @State private var isInWatchlist = false
    @State private var isWatched = false
    @State private var showNote = false
    @State private var showCustomListView = false
    var body: some View {
        VStack {
            NavigationLink(value: item) {
                WebImage(url: item.cardImageMedium)
                    .resizable()
                    .placeholder {
                        ZStack {
                            Rectangle().fill(.gray.gradient)
                            VStack {
                                Text(item.itemTitle)
                                    .font(.caption)
                                    .foregroundColor(DrawingConstants.placeholderForegroundColor)
                                    .lineLimit(1)
                                    .padding()
                                Image(systemName: item.itemContentMedia == .tvShow ? "tv" : "film")
                                    .foregroundColor(DrawingConstants.placeholderForegroundColor)
                            }
                            .padding()
                        }
                        .frame(width: DrawingConstants.imageWidth,
                               height: DrawingConstants.imageHeight)
                        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
                    }
                    .overlay {
                        if isInWatchlist {
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    if isWatched {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(DrawingConstants.placeholderForegroundColor)
                                            .padding()
                                    } else {
                                        Image(systemName: "square.stack.fill")
                                            .foregroundColor(DrawingConstants.placeholderForegroundColor)
                                            .padding()
                                    }
                                }
                                .background {
                                    if item.cardImageMedium != nil {
                                        Color.black.opacity(0.5)
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
                    .aspectRatio(contentMode: .fill)
                    .transition(.opacity)
                    .frame(width: DrawingConstants.imageWidth,
                           height: DrawingConstants.imageHeight)
                    .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius,
                                                style: .continuous))
                    .shadow(radius: DrawingConstants.imageShadow)
                    .applyHoverEffect()
                    .itemContentContextMenu(item: item,
                                            isWatched: $isWatched,
                                            showPopup: $showPopup,
                                            isInWatchlist: $isInWatchlist,
                                            showNote: $showNote,
                                            showCustomList: $showCustomListView,
                                            popupType: $popupType)
            }
#if os(tvOS)
            .buttonStyle(.card)
            .itemContentContextMenu(item: item,
                                    isWatched: $isWatched,
                                    showPopup: $showPopup,
                                    isInWatchlist: $isInWatchlist,
                                    showNote: $showNote,
                                    showCustomList: $showCustomListView,
                                    popupType: $popupType)
#endif
            HStack {
                Text(item.itemTitle)
                    .font(.caption)
                    .lineLimit(DrawingConstants.titleLineLimit)
                    .accessibilityHidden(true)
#if os(tvOS)
                    .foregroundColor(.secondary)
#endif
                Spacer()
            }
            .frame(width: DrawingConstants.imageWidth)
            Spacer()
        }
        .task {
            withAnimation {
                isInWatchlist = context.isItemSaved(id: item.itemContentID)
                if isInWatchlist && !isWatched {
                    isWatched = context.isMarkedAsWatched(id: item.itemContentID)
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
#if os(macOS)
            .frame(width: 500, height: 600, alignment: .center)
#else
            .appTheme()
            .appTint()
#endif
        }
        .accessibilityLabel(Text(item.itemTitle))
    }
}

struct CardFrame_Previews: PreviewProvider {
    static var previews: some View {
        ItemContentCardView(item: .example, showPopup: .constant(false), popupType: .constant(nil))
    }
}

private struct DrawingConstants {
#if os(macOS)
    static let imageWidth: CGFloat = 240
    static let imageHeight: CGFloat = 140
#elseif os(tvOS)
    static let imageWidth: CGFloat = 420
    static let imageHeight: CGFloat = 240
#elseif os(iOS)
    static let imageWidth: CGFloat = UIDevice.isIPad ? 240 : 160
    static let imageHeight: CGFloat = UIDevice.isIPad ? 140 : 100
#endif
    static let titleLineLimit: Int = 2
    static let imageRadius: CGFloat = 12
    static let imageShadow: CGFloat = 2.5
    static let placeholderForegroundColor: Color = .white.opacity(0.8)
}
