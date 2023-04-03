//
//  WatchlistItemFrame.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 20/12/22.
//

import SwiftUI
import SDWebImageSwiftUI
#if os(iOS) || os(macOS)
struct WatchlistItemFrame: View {
    let content: WatchlistItem
    @State private var isWatched: Bool = false
    @State private var isFavorite: Bool = false
    @State private var isPin = false
    @State private var isArchive = false
    var body: some View {
        NavigationLink(value: content) {
            VStack {
                image
                    .watchlistContextMenu(item: content,
                                          isWatched: $isWatched,
                                          isFavorite: $isFavorite,
                                          isPin: $isPin,
                                          isArchive: $isArchive)
                    .draggable(content) {
                        WebImage(url: content.largeCardImage)
                            .resizable()
                    }
                HStack {
                    Text(content.itemTitle)
                        .font(.caption)
                        .lineLimit(DrawingConstants.titleLineLimit)
                    Spacer()
                }
            }
            .frame(width: DrawingConstants.imageWidth)
            .task {
                isWatched = content.isWatched
                isFavorite = content.isFavorite
                isPin = content.isPin
                isArchive = content.isArchive
            }
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
#if os(macOS) || os(tvOS)
    static let imageWidth: CGFloat = 240
    static let imageHeight: CGFloat = 140
    static let imageRadius: CGFloat = 12
#else
    static let imageWidth: CGFloat = UIDevice.isIPad ? 240 : 160
    static let imageHeight: CGFloat = UIDevice.isIPad ? 140 : 100
    static let imageRadius: CGFloat = 8
#endif
    static let titleLineLimit: Int = 1
    static let imageShadow: CGFloat = 2.5
    static let placeholderForegroundColor: Color = .white.opacity(0.8)
}
#endif
