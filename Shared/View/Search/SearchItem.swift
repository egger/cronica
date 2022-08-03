//
//  SearchItem.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 03/08/22.
//

import SwiftUI

struct SearchItem: View {
    let item: ItemContent
    var body: some View {
        HStack {
            if item.media == .person {
                AsyncImage(url: item.itemImage,
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
                AsyncImage(url: item.itemImage,
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
                    Text(item.itemTitle)
                        .lineLimit(DrawingConstants.textLimit)
                }
                HStack {
                    Text(item.media.title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .accessibilityElement(children: .combine)
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
