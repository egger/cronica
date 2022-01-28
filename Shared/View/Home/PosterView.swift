//
//  PosterView.swift
//  Story
//
//  Created by Alexandre Madeira on 17/01/22.
//

import SwiftUI

struct PosterView: View {
    let content: Movie
    var body: some View {
        VStack {
            AsyncImage(url: content.w500PosterImage) { content in
                content
                    .resizable()
                    .scaledToFill()
                    .frame(width: DrawingConstants.posterWidth,
                           height: DrawingConstants.posterHeight)
            } placeholder: {
                ProgressView(content.title)
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
        //.redacted(reason: .placeholder) TODO: look at .redacted later on.
    }
}

struct PosterView_Previews: PreviewProvider {
    static var previews: some View {
        PosterView(content: Movie.previewMovie)
    }
}

private struct DrawingConstants {
    static let posterWidth: CGFloat = 220
    static let posterHeight: CGFloat = 360
    static let posterRadius: CGFloat = 12
    static let shadowOpacity: Double = 0.5
    static let shadowRadius: CGFloat = 5
}
