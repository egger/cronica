//
//  ItemContentList.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 26/08/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ItemContentList: View {
    let rows: [GridItem] = [
        GridItem(.adaptive(minimum: 60 ))
    ]
    let items: [ItemContent]
    var body: some View {
        VStack {
            if items.isEmpty {
                Text("Trending service ins't available right now.")
                    .font(.callout)
                    .foregroundColor(.secondary)
            } else {
                LazyHGrid(rows: rows, spacing: .zero) {
                    ForEach(items) { item in
                        ViewThatFits {
                            // Normal size for regular/Pro models.
                            PosterImage(item: item)
                                .frame(width: DrawingConstants.imageWidth,
                                       height: DrawingConstants.imageHeight)
                                .shadow(radius: 1)
                                .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
                                .padding(.leading, 4)
                                .padding(.trailing, 4)
                                .onAppear {
                                    print("Normal size")
                                }
                            
                            // Small size for SE
                            PosterImage(item: item)
                                .frame(width: DrawingConstants.smallImageWidth,
                                       height: DrawingConstants.smallImageHeight)
                                .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
                                .padding(.leading, 4)
                                .padding(.trailing, 4)
                                .onAppear {
                                    print("Small size")
                                }
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

private struct PosterImage: View {
    let item: ItemContent
    @State private var showPlaceholder = false
    var body: some View {
        Link(destination: URL(string: item.itemUrlId)!) {
            if let image = item.data {
                Image(uiImage: UIImage(data: image) ?? UIImage(systemName: "film")!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .redacted(reason: showPlaceholder ? .placeholder : [])
            } else {
                PlaceholderImage()
                    .redacted(reason: .placeholder)
            }
        }
        .task {
            if item.data == nil {
                showPlaceholder = true
            }
        }
    }
}

private struct PlaceholderImage: View {
    var body: some View {
        VStack {
            ZStack {
                Color.secondary
                Image(systemName: "film")
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 70
    static let imageHeight: CGFloat = 110
    static let smallImageWidth: CGFloat = 64
    static let smallImageHeight: CGFloat = 90
    static let imageRadius: CGFloat = 6
}
