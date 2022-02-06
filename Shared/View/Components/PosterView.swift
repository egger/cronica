//
//  PosterView.swift
//  Story
//
//  Created by Alexandre Madeira on 17/01/22.
//

import SwiftUI

struct PosterView: View {
    let title: String
    let url: URL
    var body: some View {
        VStack {
            AsyncImage(url: url) { content in
                content
                    .resizable()
                    .scaledToFill()
                    .frame(width: DrawingConstants.posterWidth,
                           height: DrawingConstants.posterHeight)
            } placeholder: {
                ProgressView(title)
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .frame(width: DrawingConstants.posterWidth,
               height: DrawingConstants.posterHeight)
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.posterRadius,
                                    style: .continuous))
        .shadow(color: .black.opacity(DrawingConstants.shadowOpacity),
                radius: DrawingConstants.shadowRadius)
    }
}

struct PosterView_Previews: PreviewProvider {
    static var previews: some View {
        PosterView(title: Movie.previewMovie.title, url: Movie.previewMovie.w500PosterImage)
    }
}

private struct DrawingConstants {
    static let posterWidth: CGFloat = 200
    static let posterHeight: CGFloat = 300
    static let posterRadius: CGFloat = 12
    static let shadowOpacity: Double = 0.5
    static let shadowRadius: CGFloat = 5
}
