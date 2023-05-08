//
//  SmallerUpNextCard.swift
//  Story
//
//  Created by Alexandre Madeira on 07/05/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct SmallerUpNextCard: View {
    let item: UpNextEpisode
    var body: some View {
        WebImage(url: item.episode.itemImageMedium ?? item.backupImage)
            .resizable()
            .placeholder {
                ZStack {
                    Rectangle().fill(.gray.gradient)
                    Image(systemName: "sparkles.tv")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 40, height: 40, alignment: .center)
                }
            }
            .aspectRatio(contentMode: .fill)
            .frame(width: DrawingConstants.imageWidth,
                   height: DrawingConstants.imageHeight)
            .transition(.opacity)
            .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
            .shadow(radius: 2)
    }
}

private struct DrawingConstants {
#if os(iOS)
    static let imageWidth: CGFloat = 160
    static let imageHeight: CGFloat = 100
#else
    static let imageWidth: CGFloat = 280
    static let imageHeight: CGFloat = 160
#endif
    static let imageRadius: CGFloat = 12
    static let titleLineLimit: Int = 1
    static let imageShadow: CGFloat = 2.5
}

