//
//  SearchItemView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 30/05/22.
//

import SwiftUI

struct SearchItemView: View {
    let content: Content?
    var body: some View {
        if let content = content {
            HStack {
                switch content.media {
                case .person: PersonImage(url: content.itemImage)
                default: CardImage(url: content.itemImage)
                }
                VStack(alignment: .leading) {
                    HStack {
                        Text(content.itemTitle)
                            .lineLimit(DrawingConstants.textLimit)
                    }
                    HStack {
                        Text(content.media.title)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
            .accessibilityElement(children: .combine)
        }
    }
}

struct SearchItemView_Previews: PreviewProvider {
    static var previews: some View {
        SearchItemView(content: Content.previewContent)
    }
}

private struct CardImage: View {
    let url: URL?
    var body: some View {
        AsyncImage(url: url,
                   transaction: Transaction(animation: .easeInOut)) { phase in
            if let image = phase.image {
                ZStack {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .transition(.opacity)
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

private struct DrawingConstants {
    static let imageWidth: CGFloat = 70
    static let imageHeight: CGFloat = 50
    static let imageRadius: CGFloat = 4
    static let textLimit: Int = 1
    static let personImageWidth: CGFloat = 60
    static let personImageHeight: CGFloat = 60
}
