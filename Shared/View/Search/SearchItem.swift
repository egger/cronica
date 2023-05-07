//
//  SearchItem.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 03/08/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct SearchItem: View {
    let item: ItemContent
    @Binding var isInWatchlist: Bool
    @Binding var isWatched: Bool
    var body: some View {
        HStack {
            if item.media == .person {
#if os(watchOS) || os(macOS)
                profile
#else
                profile
                    .hoverEffect()
#endif
            } else {
#if os(watchOS) || os(macOS)
                image
#else
                image
                    .hoverEffect()
#endif
            }
            VStack(alignment: .leading) {
                HStack {
                    Text(item.itemTitle)
                        .lineLimit(DrawingConstants.textLimit)
                }
#if os(watchOS)
                HStack {
                    Text(item.media.title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
#else
                HStack {
                    Text(item.itemSearchDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
#endif
            }
        }
        .accessibilityElement(children: .combine)
    }
    
    private var image: some View {
        WebImage(url: item.itemImage)
            .resizable()
            .placeholder {
                ZStack {
                    Color.secondary
                    Image(systemName: "film")
                }
                .frame(width: DrawingConstants.imageWidth,
                       height: DrawingConstants.imageHeight)
                .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius))
            }
            .overlay {
                if isInWatchlist {
                    ZStack {
                        Color.black.opacity(0.5)
                        if isWatched {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.white.opacity(0.8))
                                .padding()
                        } else {
                            Image(systemName: "square.stack.fill")
                                .foregroundColor(.white.opacity(0.8))
                                .padding()
                        }
                    }
                }
            }
            .aspectRatio(contentMode: .fill)
            .frame(width: DrawingConstants.imageWidth,
                   height: DrawingConstants.imageHeight)
            .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius))
            .transition(.opacity)
    }
    
    private var profile: some View {
        WebImage(url: item.itemImage)
            .resizable()
            .placeholder {
                ZStack {
                    Color.secondary
                    Image(systemName: "person")
                }
                .frame(width: DrawingConstants.personImageWidth,
                       height: DrawingConstants.personImageHeight)
                .clipShape(Circle())
            }
            .aspectRatio(contentMode: .fill)
            .transition(.opacity)
            .frame(width: DrawingConstants.personImageWidth,
                   height: DrawingConstants.personImageHeight)
            .clipShape(Circle())
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 70
    static let imageHeight: CGFloat = 50
    static let imageRadius: CGFloat = 4
    static let textLimit: Int = 1
    static let personImageWidth: CGFloat = 60
    static let personImageHeight: CGFloat = 60
}
