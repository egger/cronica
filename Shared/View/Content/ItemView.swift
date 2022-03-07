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
    let inSearch: Bool
    var body: some View {
        HStack {
            if inSearch {
                switch type {
                case .movie:
                    CardImage(url: url)
                case .person:
                    PersonImage(url: url)
                case .tvShow:
                    PosterImage(url: url)
                }
            } else {
                CardImage(url: url)
            }
            
            
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
        ItemView(title: Content.previewContent.itemTitle,
                 url: Content.previewContent.cardImage,
                 type: MediaType.movie, inSearch: false)
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 70
    static let imageHeight: CGFloat = 50
    static let imageRadius: CGFloat = 4
    static let textLimit: Int = 1
    static let personImageWidth: CGFloat = 60
    static let personImageHeight: CGFloat = 60
    static let posterImageWidth: CGFloat = 50
    static let posterImageHeight: CGFloat = 70
}

private struct CardImage: View {
    let url: URL?
    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            ZStack {
                Color.secondary
                ProgressView()
            }
        }
        .frame(width: DrawingConstants.imageWidth,
               height: DrawingConstants.imageHeight)
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius))
    }
}

private struct PersonImage: View {
    let url: URL?
    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            ZStack {
                Color.secondary
                ProgressView()
            }
        }
        .frame(width: DrawingConstants.personImageWidth,
               height: DrawingConstants.personImageHeight)
        .clipShape(Circle())
    }
}

private struct PosterImage: View {
    let url: URL?
    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            ZStack {
                Color.secondary
                ProgressView()
            }
        }
        .frame(width: DrawingConstants.posterImageWidth,
               height: DrawingConstants.posterImageHeight)
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius))
    }
}
