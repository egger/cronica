//
//  PersonSearchImage.swift
//  CronicaMac
//
//  Created by Alexandre Madeira on 20/11/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct PersonSearchImage: View {
    let item: ItemContent
    var body: some View {
        NavigationLink(value: item) {
            WebImage(url: item.itemImage, options: .highPriority)
                .resizable()
                .placeholder {
                    PersonSearchImagePlaceholder()
                }
                .aspectRatio(contentMode: .fill)
                .transition(.opacity)
                .frame(width: DrawingConstants.posterWidth,
                       height: DrawingConstants.posterHeight)
                .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.posterRadius,
                                            style: .continuous))
                .shadow(radius: DrawingConstants.shadowRadius)
                .padding(.zero)
                .contextMenu {
                    ShareLink(item: item.itemSearchURL)
                }
        }
    }
}

private struct PersonSearchImagePlaceholder: View {
    var body: some View {
        ZStack {
            Rectangle().fill(.gray.gradient)
            Image(systemName: "person")
                .font(.title)
                .foregroundColor(.secondary)
        }
        .frame(width: DrawingConstants.posterWidth,
               height: DrawingConstants.posterHeight)
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.posterRadius,
                                    style: .continuous))
        .shadow(radius: DrawingConstants.shadowRadius)
        .padding(.zero)
    }
}

private struct DrawingConstants {
    static let posterWidth: CGFloat = 160
    static let posterHeight: CGFloat = 240
    static let posterRadius: CGFloat = 8
    static let shadowRadius: CGFloat = 2
}

