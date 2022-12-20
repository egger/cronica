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
            .frame(width: UIDevice.isIPad ? DrawingConstants.padImageWidth : DrawingConstants.imageWidth)
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
            .frame(width: UIDevice.isIPad ? DrawingConstants.padImageWidth :  DrawingConstants.imageWidth,
                   height: UIDevice.isIPad ? DrawingConstants.padImageHeight : DrawingConstants.imageHeight)
            .clipShape(RoundedRectangle(cornerRadius: UIDevice.isIPad ? DrawingConstants.padImageRadius : DrawingConstants.imageRadius,
                                        style: .continuous))
            .shadow(radius: DrawingConstants.imageShadow)
            .hoverEffect(.lift)
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
        .frame(width: UIDevice.isIPad ? DrawingConstants.padImageWidth :  DrawingConstants.imageWidth,
               height: UIDevice.isIPad ? DrawingConstants.padImageHeight : DrawingConstants.imageHeight)
        .clipShape(RoundedRectangle(cornerRadius: UIDevice.isIPad ? DrawingConstants.padImageRadius : DrawingConstants.imageRadius, style: .continuous))
    }
}

struct WatchlistItemFrame_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistItemFrame(content: .example)
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 160
    static let imageHeight: CGFloat = 100
    static let imageRadius: CGFloat = 8
    static let imageShadow: CGFloat = 2.5
#if os(macOS)
#else
#endif
    static let padImageWidth: CGFloat = 240
    static let padImageHeight: CGFloat = 140
    static let padImageRadius: CGFloat = 12
    static let titleLineLimit: Int = 1
    static let placeholderForegroundColor: Color = .white.opacity(0.8)
}
