//
//  WatchlistItemCardView.swift
//  Cronica
//
//  Created by Alexandre Madeira on 20/12/22.
//

import SwiftUI
import NukeUI

struct WatchlistItemCardView: View {
    let content: WatchlistItem
    @State private var isWatched: Bool = false
    @State private var isFavorite: Bool = false
    @State private var isPin = false
    @State private var isArchive = false
    @State private var showNote = false
    @State private var showCustomListView = false
    @Binding var showPopup: Bool
    @Binding var popupType: ActionPopupItems?
#if os(tvOS)
    @FocusState var isStackFocused: Bool
#elseif os(macOS)
    
#endif
    var body: some View {
        VStack {
            NavigationLink(value: content) {
                LazyImage(url: content.backCompatibleCardImage) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        placeholder
                    }
                }
                .transition(.opacity)
                .overlay {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            if isPin {
                                Image(systemName: "pin.fill")
                                    .imageScale(.small)
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding([.vertical])
                                    .padding(.trailing, 4)
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
                            if content.backCompatibleCardImage != nil {
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
                .frame(width: DrawingConstants.imageWidth,
                       height: DrawingConstants.imageHeight)
                .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius,
                                            style: .continuous))
                .shadow(radius: DrawingConstants.imageShadow)
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
            }
            HStack {
                Text(content.itemTitle)
                    .font(.caption)
                    .lineLimit(DrawingConstants.titleLineLimit)
#if os(tvOS)
                    .foregroundColor(isStackFocused ? .primary : .secondary)
                    .padding(.vertical, 4)
#endif
                Spacer()
            }
            Spacer()
        }
        .frame(width: DrawingConstants.imageWidth)
        .task {
            isWatched = content.isWatched
            isFavorite = content.isFavorite
            isPin = content.isPin
            isArchive = content.isArchive
        }
#if os(tvOS)
        .buttonStyle(.card)
        .watchlistContextMenu(item: content,
                              isWatched: $isWatched,
                              isFavorite: $isFavorite,
                              isPin: $isPin,
                              isArchive: $isArchive,
                              showNote: $showNote,
                              showCustomList: $showCustomListView,
                              popupType: $popupType,
                              showPopup: $showPopup)
        .focused($isStackFocused)
#endif
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
                                              title: content.itemTitle, image: content.backCompatibleCardImage)
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
    private var tvOSOverlay: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Spacer()
                ZStack {
                    Color.black.opacity(0.4)
                        .frame(height: 50)
                        .mask {
                            LinearGradient(colors: [Color.black,
                                                    Color.black.opacity(0.924),
                                                    Color.black.opacity(0.707),
                                                    Color.black.opacity(0.383),
                                                    Color.black.opacity(0)],
                                           startPoint: .bottom,
                                           endPoint: .top)
                        }
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .frame(height: 70)
                        .mask {
                            VStack(spacing: 0) {
                                LinearGradient(colors: [Color.black.opacity(0),
                                                        Color.black.opacity(0.383),
                                                        Color.black.opacity(0.707),
                                                        Color.black.opacity(0.924),
                                                        Color.black],
                                               startPoint: .top,
                                               endPoint: .bottom)
                                .frame(height: 50)
                                Rectangle()
                            }
                        }
                }
            }
            HStack {
                Text(content.itemTitle)
                    .font(.callout)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .padding([.leading, .bottom])
                Spacer()
            }
            
        }
    }
    
    private var placeholder: some View {
        ZStack {
            Rectangle().fill(.gray.gradient)
            VStack {
                Image(systemName: "popcorn.fill")
                    .font(.title)
                    .fontWidth(.expanded)
                    .foregroundColor(.white.opacity(0.8))
                    .padding()
            }
            .padding()
        }
        .frame(width: DrawingConstants.imageWidth,
               height: DrawingConstants.imageHeight)
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
    }
}

#Preview {
    WatchlistItemCardView(content: .example, showPopup: .constant(false), popupType: .constant(nil))
}

private struct DrawingConstants {
#if os(macOS) || os(visionOS)
    static let imageWidth: CGFloat = 240
    static let imageHeight: CGFloat = 140
#elseif os(iOS)
    static let imageWidth: CGFloat = UIDevice.isIPad ? 240 : 160
    static let imageHeight: CGFloat = UIDevice.isIPad ? 140 : 100
#elseif os(tvOS)
    static let imageWidth: CGFloat = 420
    static let imageHeight: CGFloat = 240
#endif
    static let imageRadius: CGFloat = 8
    static let titleLineLimit: Int = 2
    static let imageShadow: CGFloat = 2.5
    static let placeholderForegroundColor: Color = .white.opacity(0.8)
}

