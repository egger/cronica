//
//  ItemView.swift
//  Story
//
//  Created by Alexandre Madeira on 19/01/22.
//

import SwiftUI

struct ItemView: View {
    let content: Movie
    var body: some View {
        GroupBox {
            HStack {
                AsyncImage(url: content.w500PosterImage) { content in
                    content
                        .resizable()
                        .scaledToFill()
                        .frame(width: DrawingConstants.posterWidth,
                               height: DrawingConstants.posterHeight)
                        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.posterRadius,
                                                    style: .continuous))
                } placeholder: {
                    Rectangle()
                        .fill(.secondary)
                        .redacted(reason: .placeholder)
                        .frame(width: DrawingConstants.posterWidth,
                               height: DrawingConstants.posterHeight)
                        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.posterRadius,
                                                    style: .continuous))
                }
                VStack {
                    Text(content.title)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct ItemView_Previews: PreviewProvider {
    static var previews: some View {
        ItemView(content: Movie.previewMovie)
    }
}

private struct DrawingConstants {
    static let posterWidth: CGFloat = 140
    static let posterHeight: CGFloat = 200
    static let posterRadius: CGFloat = 12
    static let shadowOpacity: Double = 0.5
    static let shadowRadius: CGFloat = 5
}
