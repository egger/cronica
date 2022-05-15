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
    var inSearch: Bool = false
    var watched: Bool = false
    var favorite: Bool = false
    var body: some View {
        HStack {
            if inSearch {
                switch type {
                case .person:
                    PersonImage(url: url)
                default:
                    CardImage(url: url, watched: watched)
                }
            } else {
                CardImage(url: url, watched: watched)
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
            if favorite {
                Spacer()
                Image(systemName: "heart.fill")
                    .symbolRenderingMode(.multicolor)
            }
        }
    }
}

struct ItemView_Previews: PreviewProvider {
    static var previews: some View {
        ItemView(title: Content.previewContent.itemTitle,
                 url: Content.previewContent.cardImageMedium,
                 type: MediaType.movie, inSearch: false)
    }
}

private struct CardImage: View {
    let url: URL?
    var watched: Bool
    var body: some View {
        AsyncImage(url: url,
                   transaction: Transaction(animation: .easeInOut)) { phase in
            if let image = phase.image {
                ZStack {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .transition(.opacity)
                    if watched {
                        Color.black.opacity(0.6)
                        Image(systemName: "checkmark.circle.fill").foregroundColor(.white)
                    }
                }
            } else if phase.error != nil {
                ZStack {
                    Color.secondary
                    ProgressView()
                }
            } else {
                ZStack {
                    Color.secondary
                    Image(systemName: "film")
                }
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
        AsyncImage(url: url,
                   transaction: Transaction(animation: .easeInOut)) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .transition(.opacity)
            } else if phase.error != nil {
                ZStack {
                    ProgressView()
                }.background(.secondary)
            } else {
                ZStack {
                    Color.secondary
                    Image(systemName: "person")
                }
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
        AsyncImage(url: url,
                   transaction: Transaction(animation: .easeInOut)) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .transition(.opacity)
            } else if phase.error != nil {
                ZStack {
                    Rectangle().fill(.secondary)
                    ProgressView()
                }
            } else {
                ZStack {
                    Color.secondary
                    Image(systemName: "film")
                }
            }
        }
        .frame(width: DrawingConstants.posterImageWidth,
               height: DrawingConstants.posterImageHeight)
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius))
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
