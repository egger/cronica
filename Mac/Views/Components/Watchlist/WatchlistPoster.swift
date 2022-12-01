//
//  WatchlistPoster.swift
//  CronicaMac
//
//  Created by Alexandre Madeira on 17/11/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct WatchlistPoster: View {
    let item: WatchlistItem
    private let context = PersistenceController.shared
    @State private var isWatched = false
    @State private var isFavorite = false
    @State private var isPin = false
    @State private var isArchive = false
    var body: some View {
        NavigationLink(value: item) {
            WebImage(url: item.mediumPosterImage, options: .highPriority)
                .resizable()
                .placeholder {
                    ZStack {
                        Rectangle().fill(Color.gray.gradient)
                        VStack {
                            Text(item.itemTitle)
                                .lineLimit(1)
                                .padding()
                            Image(systemName: item.itemMedia == .tvShow ? "tv" : "film")
                                .font(.title)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(width: DrawingConstants.posterWidth,
                           height: DrawingConstants.posterHeight)
                    .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.posterRadius,
                                                style: .continuous))
                    .shadow(radius: DrawingConstants.shadowRadius)
                    .padding(.zero)
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
                .modifier(
                    WatchlistItemContextMenu(item: item,
                                             isWatched: $isWatched,
                                             isFavorite: $isFavorite,
                                             isPin: $isPin,
                                             isArchive: $isArchive)
                )
                .task {
                    withAnimation {
                        isWatched = item.isWatched
                        isFavorite = item.isFavorite
                        isPin = item.isPin
                        isArchive = item.isArchive
                    }
                }
#if os(macOS)
                .draggable(item)
#endif
        }
    }
}

struct WatchlistPoster_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistPoster(item: WatchlistItem.example)
    }
}

private struct DrawingConstants {
    static let posterWidth: CGFloat = 160
    static let posterHeight: CGFloat = 240
    static let posterRadius: CGFloat = 12
    static let shadowRadius: CGFloat = 2
}
