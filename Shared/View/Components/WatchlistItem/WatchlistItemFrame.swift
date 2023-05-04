//
//  WatchlistItemFrame.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 20/12/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct WatchlistItemFrame: View {
    let content: WatchlistItem
    @State private var isWatched: Bool = false
    @State private var isFavorite: Bool = false
    @State private var isPin = false
    @State private var isArchive = false
    @State private var showNote = false
    var body: some View {
        NavigationLink(value: content) {
            VStack {
                image
                    .watchlistContextMenu(item: content,
                                          isWatched: $isWatched,
                                          isFavorite: $isFavorite,
                                          isPin: $isPin,
                                          isArchive: $isArchive,
                                          showNote: $showNote)
#if os(iOS) || os(macOS)
                    .draggable(content) {
                        WebImage(url: content.largeCardImage)
                            .resizable()
                    }
#endif
#if os(iOS) || os(macOS)
                HStack {
                    Text(content.itemTitle)
                        .font(.caption)
                        .lineLimit(DrawingConstants.titleLineLimit)
                    Spacer()
                }
#endif
            }
            .frame(width: DrawingConstants.imageWidth)
            .task {
                isWatched = content.isWatched
                isFavorite = content.isFavorite
                isPin = content.isPin
                isArchive = content.isArchive
            }
        }
#if os(tvOS)
        .buttonStyle(.card)
#endif
        .sheet(isPresented: $showNote) {
            NavigationStack {
                WatchlistItemNoteView(id: content.notificationID, showView: $showNote)
            }
            .presentationDetents([.medium, .large])
#if os(macOS)
            .frame(width: 400, height: 400, alignment: .center)
#elseif os(iOS)
                .appTheme()
                .appTint()
#endif
        }
    }
    private var image: some View {
        WebImage(url: content.largeCardImage)
            .resizable()
            .placeholder { placeholder }
            .aspectRatio(contentMode: .fill)
            .transition(.opacity)
            .frame(width: DrawingConstants.imageWidth,
                   height: DrawingConstants.imageHeight)
            .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius,
                                        style: .continuous))
            .shadow(radius: DrawingConstants.imageShadow)
            .applyHoverEffect()
#if os(tvOS)
            .overlay {
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
#endif
    }
    private var placeholder: some View {
        ZStack {
            Rectangle().fill(.gray.gradient)
            VStack {
                Text(content.itemTitle)
                    .font(.caption)
                    .foregroundColor(DrawingConstants.placeholderForegroundColor)
                    .lineLimit(1)
                    .padding()
                Image(systemName: content.itemMedia == .tvShow ? "tv" : "film")
                    .foregroundColor(DrawingConstants.placeholderForegroundColor)
            }
            .padding()
        }
        .frame(width: DrawingConstants.imageWidth,
               height: DrawingConstants.imageHeight)
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
    }
}

struct WatchlistItemFrame_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistItemFrame(content: .example)
    }
}

private struct DrawingConstants {
#if os(macOS)
    static let imageWidth: CGFloat = 240
    static let imageHeight: CGFloat = 140
    static let imageRadius: CGFloat = 12
#elseif os(iOS)
    static let imageWidth: CGFloat = UIDevice.isIPad ? 240 : 160
    static let imageHeight: CGFloat = UIDevice.isIPad ? 140 : 100
    static let imageRadius: CGFloat = 8
#elseif os(tvOS)
    static let imageWidth: CGFloat = 460
    static let imageHeight: CGFloat = 260
    static let imageRadius: CGFloat = 12
#endif
    static let titleLineLimit: Int = 1
    static let imageShadow: CGFloat = 2.5
    static let placeholderForegroundColor: Color = .white.opacity(0.8)
}

