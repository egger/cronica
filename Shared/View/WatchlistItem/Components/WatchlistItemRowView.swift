//
//  WatchlistItemRowView.swift
//  Story
//
//  Created by Alexandre Madeira on 07/02/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct WatchlistItemRowView: View {
    let content: WatchlistItem
    @State private var isWatched: Bool = false
    @State private var isFavorite: Bool = false
    @State private var isPin = false
    @State private var isArchive = false
    @StateObject private var settings = SettingsStore.shared
    @State private var showNote = false
    @State private var showCustomListView = false
    @Binding var showPopup: Bool
    @Binding var popupType: ActionPopupItems?
    var body: some View {
        NavigationLink(value: content) {
            HStack {
                image
                    .applyHoverEffect()
#if !os(watchOS)
                    .shadow(radius: 2.5)
#else
                    .padding(.vertical)
#endif
                VStack(alignment: .leading) {
                    HStack {
                        Text(content.itemTitle)
                            .lineLimit(DrawingConstants.textLimit)
                            .fontDesign(.rounded)
                    }
                    HStack {
                        Text(content.itemMedia.title)
                            .fontDesign(.rounded)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                .padding(.leading, 2)
#if !os(watchOS)
                Spacer()
                IconGridView(isFavorite: $isFavorite, isPin: $isPin)
                    .accessibilityHidden(true)
#endif
            }
            .task {
                isWatched = content.isWatched
                isFavorite = content.isFavorite
                isPin = content.isPin
                isArchive = content.isArchive
            }
#if os(iOS) || os(macOS)
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
#endif
            .sheet(isPresented: $showCustomListView) {
                NavigationStack {
                    ItemContentCustomListSelector(contentID: content.itemContentID,
                                                  showView: $showCustomListView,
                                                  title: content.itemTitle,
                                                  image: content.image)
                }
                .presentationDetents([.large])
#if os(macOS)
                .frame(width: 500, height: 600, alignment: .center)
#else
                .appTheme()
                .appTint()
#endif
            }
            .accessibilityElement(children: .combine)
#if !os(watchOS)
            .watchlistContextMenu(item: content,
                                  isWatched: $isWatched,
                                  isFavorite: $isFavorite,
                                  isPin: $isPin,
                                  isArchive: $isArchive,
                                  showNote: $showNote,
                                  showCustomList: $showCustomListView,
                                  popupType: $popupType,
                                  showPopup: $showPopup)
#endif
        }
    }
    
    private var image: some View {
        ZStack {
            WebImage(url: content.image)
                .placeholder {
                    ZStack {
                        Rectangle().fill(.gray.gradient)
                        Image(systemName: "popcorn.fill")
                            .font(.title3)
                            .fontWidth(.expanded)
                            .foregroundColor(.white.opacity(0.8))
                            .padding()
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
        WatchlistItemRowView(content: .example, showPopup: .constant(false), popupType: .constant(nil))
    }
}

private struct DrawingConstants {
#if os(watchOS)
    static let imageWidth: CGFloat = 70
    static let textLimit: Int = 2
#else
    static let imageWidth: CGFloat = 80
    static let textLimit: Int = 1
#endif
    static let imageHeight: CGFloat = 50
    static let imageRadius: CGFloat = 8
}

import SwiftUI

struct IconGridView: View {
    @Binding var isFavorite: Bool
    @Binding var isPin: Bool
    
    var body: some View {
        if isSingleIconVisible {
            // Display the single icon alone, bigger.
            getSingleIcon()
                .imageScale(.medium)
                .symbolRenderingMode(.multicolor)
                .padding()
        } else if hasNoIcon {
            EmptyView()
        } else {
            VStack {
                iconImage(systemName: "heart.fill", isVisible: isFavorite)
                    .padding(.bottom, 1)
                iconImage(systemName: "pin.fill", isVisible: isPin)
            }
        }
    }
    
    @ViewBuilder
    private func iconImage(systemName: String, isVisible: Bool) -> some View {
        if isVisible {
            Image(systemName: systemName)
                .imageScale(.small)
                .symbolRenderingMode(.multicolor)
                .padding(.trailing)
        } else {
            Color.clear  // Placeholder to maintain layout even if icon is hidden
        }
    }
    
    private var isSingleIconVisible: Bool {
        let visibleIconsCount = [isFavorite, isPin].filter { $0 }.count
        return visibleIconsCount == 1
    }
    
    private var hasNoIcon: Bool {
        let visibleIconsCount = [isFavorite, isPin].filter { $0 }.count
        return visibleIconsCount == 0
    }
    
    private func getSingleIcon() -> Image {
        if isFavorite {
            return Image(systemName: "heart.fill")
        } else {
            return Image(systemName: "pin.fill")
        }
    }
}
