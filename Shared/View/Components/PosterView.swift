//
//  PosterView.swift
//  Story
//
//  Created by Alexandre Madeira on 17/01/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct PosterView: View {
    let item: ItemContent
    var body: some View {
        WebImage(url: item.posterImageMedium, options: .highPriority)
            .resizable()
            .placeholder {
                PosterPlaceholder(title: item.itemTitle)
            }
            .aspectRatio(contentMode: .fill)
            .transition(.opacity)
            .frame(width: DrawingConstants.posterWidth,
                   height: DrawingConstants.posterHeight)
            .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.posterRadius,
                                        style: .continuous))
            .shadow(color: .black.opacity(DrawingConstants.shadowOpacity),
                    radius: DrawingConstants.shadowRadius)
            .draggable(item)
    }
}

struct PosterView_Previews: PreviewProvider {
    static var previews: some View {
        PosterView(item: ItemContent.previewContent)
    }
}

private struct PosterPlaceholder: View {
    var title: String
    var body: some View {
        ZStack {
            Rectangle().fill(.thickMaterial)
            VStack {
                Text(title)
                    .lineLimit(1)
                    .padding(.bottom)
                Image(systemName: "film")
            }
            .padding()
            .foregroundColor(.secondary)
        }
        .frame(width: DrawingConstants.posterWidth,
               height: DrawingConstants.posterHeight)
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.posterRadius,
                                    style: .continuous))
        .shadow(color: .black.opacity(DrawingConstants.shadowOpacity),
                radius: DrawingConstants.shadowRadius)
    }
}

private struct DrawingConstants {
    static let posterWidth: CGFloat = 160
    static let posterHeight: CGFloat = 240
    static let posterRadius: CGFloat = 8
    static let shadowOpacity: Double = 0.5
    static let shadowRadius: CGFloat = 2.5
}
