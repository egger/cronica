//
//  DetailsImageView.swift
//  Story
//
//  Created by Alexandre Madeira on 28/01/22.
//

import SwiftUI

struct DetailsImageView: View {
    let image: URL
    let placeholderTitle: String
    var body: some View {
        AsyncImage(url: image) { content in
            content
                .resizable()
                .scaledToFill()
                .frame(width: DrawingConstants.imageWidth,
                       height: DrawingConstants.imageHeight,
                       alignment: .center)
                .cornerRadius(DrawingConstants.imageRadius)
                .shadow(color: .black.opacity(DrawingConstants.shadowOpacity),
                        radius: DrawingConstants.shadowRadius)
        } placeholder: {
            Rectangle()
                .frame(width: DrawingConstants.imageWidth,
                       height: DrawingConstants.imageHeight)
                .background(.secondary)
                .cornerRadius(DrawingConstants.imageRadius)
                .shadow(color: .black.opacity(DrawingConstants.shadowOpacity),
                        radius: DrawingConstants.shadowRadius)
                .redacted(reason: .placeholder)
        }
        .padding([.top, .bottom])
    }
}

struct MovieImageView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsImageView(image: Movie.previewMovie.backdropImage,
                       placeholderTitle: Movie.previewMovie.title)
    }
}

private struct DrawingConstants {
    static let shadowOpacity: Double = 0.5
    static let shadowRadius: CGFloat = 5
    static let imageWidth: CGFloat = 360
    static let imageHeight: CGFloat = 220
    static let imageRadius: CGFloat = 12
}
