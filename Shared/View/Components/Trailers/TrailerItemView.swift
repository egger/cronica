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
                .contextMenu {
                    if let url = trailer.url {
                        ShareLink(item: url)
                        Button("Open in YouTube") {
                            #if os(iOS)
                            UIApplication.shared.open(url)
                            #endif
                        }
                    }
                }
            #warning(".hoverEffect()")
            HStack {
                Text(trailer.title)
                    .lineLimit(DrawingConstants.lineLimits)
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
            Color.black.opacity(DrawingConstants.overlayOpacity)
            Image(systemName: "play.circle.fill")
                .resizable()
                .frame(width: DrawingConstants.overlayWidth,
                       height: DrawingConstants.overlayHeight,
                       alignment: .center)
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
    static let overlayOpacity: Double = 0.1
    static let overlayWidth: CGFloat = 40
    static let overlayHeight: CGFloat = 40
    static let lineLimits: Int = 1
}
