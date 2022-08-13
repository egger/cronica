//
//  ListItemView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 13/08/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ListItemView: View {
    var item: WatchlistItem
    var title: String
    var itemCount: String
    var body: some View {
        HStack {
            WebImage(url: item.image)
                .placeholder {
                    ZStack {
                        Color.secondary
                        Image(systemName: "film")
                    }
                    .frame(width: DrawingConstants.imageWidth,
                           height: DrawingConstants.imageHeight)
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .transition(.opacity)
                .frame(width: DrawingConstants.imageWidth,
                       height: DrawingConstants.imageHeight)
                .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius))
            VStack(alignment: .leading) {
                Text(title)
                    .lineLimit(DrawingConstants.textLimit)
                HStack {
                    Text(itemCount)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 70
    static let imageHeight: CGFloat = 50
    static let imageRadius: CGFloat = 4
    static let textLimit: Int = 1
}
