//
//  ItemView.swift
//  Story
//
//  Created by Alexandre Madeira on 07/02/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ItemView: View {
    let content: WatchlistItem
    var body: some View {
        HStack {
            ZStack {
                WebImage(url: content.image)
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
                if content.watched {
                    Color.black.opacity(0.6)
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.white)
                }
            }
            .frame(width: DrawingConstants.imageWidth,
                   height: DrawingConstants.imageHeight)
            .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius))
            VStack(alignment: .leading) {
                HStack {
                    Text(content.itemTitle)
                        .lineLimit(DrawingConstants.textLimit)
                }
                HStack {
                    Text(content.itemMedia.title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            if content.favorite {
                Spacer()
                Image(systemName: "heart.fill")
                    .symbolRenderingMode(.multicolor)
                    .padding(.trailing)
                    .accessibilityLabel("\(content.itemTitle) is favorite.")
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct ItemView_Previews: PreviewProvider {
    static var previews: some View {
        ItemView(content: WatchlistItem.example)
    }
}


private struct DrawingConstants {
    static let imageWidth: CGFloat = 70
    static let imageHeight: CGFloat = 50
    static let imageRadius: CGFloat = 4
    static let textLimit: Int = 1
}
