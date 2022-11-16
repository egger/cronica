//
//  PosterWatchlistItem.swift
//  CronicaMac
//
//  Created by Alexandre Madeira on 03/11/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct PosterWatchlistItem: View {
    let item: WatchlistItem
    @State private var isPin = false
    @State private var isFavorite = false
    @State private var isWatched = false
    var body: some View {
        NavigationLink(value: item) {
            WebImage(url: item.mediumPosterImage)
                .resizable()
                .placeholder {
                    ZStack {
                        Rectangle().fill(.gray.gradient)
                        VStack {
                            Text(item.itemTitle)
                                .font(.callout)
                                .lineLimit(1)
                                .foregroundColor(.white)
                                .padding(.bottom)
                            Image(systemName: item.isMovie ? "film" : "tv")
                                .font(.title)
                                .foregroundColor(.white)
                                .opacity(0.8)
                        }
                        .padding()
                    }
                    .frame(width: DrawingConstants.posterWidth,
                           height: DrawingConstants.posterHeight)
                    .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.posterRadius,
                                                style: .continuous))
                    .shadow(radius: DrawingConstants.shadowRadius)
                    .applyHoverEffect()
                }
                .aspectRatio(contentMode: .fill)
                .transition(.opacity)
                .frame(width: DrawingConstants.posterWidth,
                       height: DrawingConstants.posterHeight)
                .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.posterRadius,
                                            style: .continuous))
                .shadow(radius: DrawingConstants.shadowRadius)
                .padding(.zero)
                .applyHoverEffect()
                .draggable(item)
                .modifier(WatchlistItemContextMenu(item: item,
                                                   isWatched: $isWatched,
                                                   isFavorite: $isFavorite,
                                                   isPin: $isPin))
                .task {
                    isWatched = item.isWatched
                    isFavorite = item.isFavorite
                    isPin = item.isPin
                }
        }
    }
}

struct PosterWatchlistItem_Previews: PreviewProvider {
    static var previews: some View {
        PosterWatchlistItem(item: WatchlistItem.example)
    }
}

private struct DrawingConstants {
    static let posterWidth: CGFloat = 160
    static let posterHeight: CGFloat = 240
    static let posterRadius: CGFloat = 12
    static let shadowRadius: CGFloat = 2
}
