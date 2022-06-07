//
//  SearchItemView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 30/05/22.
//

import SwiftUI

struct SearchItemView: View {
    let content: ItemContent?
    var body: some View {
        if let content {
            HStack {
                if content.media == .person {
                    AsyncImage(url: content.itemImage,
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
                } else {
                    AsyncImage(url: content.itemImage,
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
        SearchItemView(content: ItemContent.previewContent)
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
