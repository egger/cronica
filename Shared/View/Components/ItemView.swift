//
//  ItemView.swift
//  Story
//
//  Created by Alexandre Madeira on 07/02/22.
//

import SwiftUI

struct ItemView: View {
    let title: String
    let url: URL?
    let type: MediaType
    var body: some View {
        HStack {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ZStack {
                    Rectangle()
                        .fill(.secondary)
                    ProgressView()
                }
            }
            .frame(width: DrawingConstants.imageWidth, height: DrawingConstants.imageHeight)
            .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius))
            VStack(alignment: .leading) {
                HStack {
                    Text(title)
                        .lineLimit(DrawingConstants.textLimit)
                }
                HStack {
                    Text(type.title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
    }
}

struct ItemView_Previews: PreviewProvider {
    static var previews: some View {
        ItemView(title: Movie.previewMovie.title, url: Movie.previewMovie.backdropImage, type: MediaType.movie)
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 70
    static let imageHeight: CGFloat = 50
    static let imageRadius: CGFloat = 4
    static let textLimit: Int = 1
}
