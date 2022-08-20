//
//  TrailerItemView.swift
//  Story
//
//  Created by Alexandre Madeira on 20/08/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct TrailerItemView: View {
    let trailer: VideoItem
    var body: some View {
        VStack {
            WebImage(url: trailer.thumbnail)
                .resizable()
                .placeholder {
                    placeholder
                }
                .aspectRatio(contentMode: .fill)
                .transition(.opacity)
                .frame(width: DrawingConstants.imageWidth,
                       height: DrawingConstants.imageHeight)
                .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius,
                                            style: .continuous))
                .overlay {
                    overlay
                }
            HStack {
                Text(trailer.title)
                    .lineLimit(1)
                    .padding([.trailing, .bottom])
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .frame(width: DrawingConstants.imageWidth)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(trailer.title)
    }
    var placeholder: some View {
        ZStack {
            Color.secondary
            Image(systemName: "play.fill")
                .foregroundColor(.white)
                .imageScale(.medium)
        }
        .transition(.opacity)
        .frame(width: DrawingConstants.imageWidth,
               height: DrawingConstants.imageHeight)
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius,
                                    style: .continuous))
    }
    var overlay: some View {
        ZStack {
            Color.black.opacity(0.1)
            Image(systemName: "play.circle.fill")
                .resizable()
                .frame(width: 40, height: 40, alignment: .center)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, .secondary)
                .scaledToFit()
                .imageScale(.medium)
                .padding()
        }
        .frame(width: DrawingConstants.imageWidth,
               height: DrawingConstants.imageHeight)
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius,
                                    style: .continuous))
    }
}

private struct DrawingConstants {
    static let imageRadius: CGFloat = 12
    static let imageShadow: CGFloat = 2.5
    static let imageWidth: CGFloat = 220
    static let imageHeight: CGFloat = 120
}
