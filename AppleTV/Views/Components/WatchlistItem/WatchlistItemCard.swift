//
//  WatchlistItemCard.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 29/10/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct WatchlistItemCard: View {
    let item: WatchlistItem
    @State private var isWatched = false
    @State private var isFavorite = false
    @State private var isPin = false
    @State private var isArchive = false
    var body: some View {
        NavigationLink(value: item) {
            WebImage(url: item.itemImage)
                .resizable()
                .placeholder {
                    VStack {
                        if item.itemMedia == .movie {
                            Image(systemName: "film")
                        } else {
                            Image(systemName: "tv")
                        }
                        Text(item.itemTitle)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                            .padding()
                    }
                    .frame(width: DrawingConstants.imageWidth,
                           height: DrawingConstants.imageHeight)
                    .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
                }
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
                            Text(item.itemTitle)
                                .font(.callout)
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .padding([.leading, .bottom])
                            Spacer()
                        }
                        
                    }
                }
                .frame(width: DrawingConstants.imageWidth,
                       height: DrawingConstants.imageHeight)
                .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
                .aspectRatio(contentMode: .fill)
                .task {
                    isWatched = item.isWatched
                    isFavorite = item.isFavorite
                    isPin = item.isPin
                    isArchive = item.isArchive
                }
        }
        .buttonStyle(.card)
        .ignoresSafeArea(.all)
        .modifier(WatchlistItemContextMenu(item: item,
                                           isWatched: $isWatched,
                                           isFavorite: $isFavorite,
                                           isPin: $isPin,
                                           isArchive: $isArchive))
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 460
    static let imageHeight: CGFloat = 260
    static let imageRadius: CGFloat = 8
    static let titleLineLimit: Int = 1
    static let imageShadow: CGFloat = 2.5
}

struct WatchlistItemCard_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistItemCard(item: WatchlistItem.example)
    }
}
