//
//  EpisodeItemView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 28/04/22.
//

import SwiftUI

struct EpisodeItemView: View {
    let item: Episode
    var body: some View {
        HStack {
            AsyncImage(url: item.itemImageMedium) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                else if phase.error != nil {
                    ZStack {
                        Rectangle().fill(.secondary)
                        ProgressView()
                    }
                } else {
                    ZStack {
                        Rectangle().fill(.secondary)
                        Image(systemName: "tv")
                    }
                }
            }
            .frame(width: DrawingConstants.imageWidth, height: DrawingConstants.imageHeight)
            .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius))
            VStack(alignment: .leading) {
                Text(item.itemTitle)
                    .lineLimit(1)
                    .font(.callout)
                    .padding([.top, .bottom], 2)
                    .foregroundColor(.primary)
                Text(item.itemAbout)
                    .lineLimit(2)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
            }
            Spacer()
        }
        .buttonStyle(.plain)
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 120
    static let imageHeight: CGFloat = 80
    static let imageRadius: CGFloat = 4
}
