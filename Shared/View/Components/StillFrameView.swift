//
//  StillFrameView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 01/05/22.
//

import SwiftUI

struct StillFrameView: View {
    let image: URL?
    let title: String
    var body: some View {
        VStack {
            AsyncImage(url: image,
                       transaction: Transaction(animation: .easeInOut)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .transition(.opacity)
                } else if phase.error != nil {
                    ZStack {
                        Rectangle().fill(.thickMaterial)
                        VStack {
                            Text(title)
                                .font(.callout)
                                .lineLimit(1)
                                .padding(.bottom)
                            Image(systemName: "film")
                        }
                        .padding()
                        .foregroundColor(.secondary)
                    }
                } else {
                    ZStack {
                        Rectangle().fill(.thickMaterial)
                        VStack {
                            ProgressView()
                                .padding(.bottom)
                            Image(systemName: "film")
                        }
                        .padding()
                        .foregroundColor(.secondary)
                    }
                }
            }
            .frame(width: UIDevice.isIPad ? DrawingConstants.padImageWidth :  DrawingConstants.imageWidth,
                   height: UIDevice.isIPad ? DrawingConstants.padImageHeight : DrawingConstants.imageHeight)
            .clipShape(RoundedRectangle(cornerRadius: UIDevice.isIPad ? DrawingConstants.padImageRadius : DrawingConstants.imageRadius,
                                        style: .continuous))
            HStack {
                Text(title)
                    .font(.caption)
                    .lineLimit(DrawingConstants.titleLineLimit)
                Spacer()
            }
            .frame(width: UIDevice.isIPad ? DrawingConstants.padImageWidth : DrawingConstants.imageWidth)
        }
    }
}

struct StillFrameView_Previews: PreviewProvider {
    static var previews: some View {
        StillFrameView(image: Content.previewContent.cardImageMedium,
                       title: Content.previewContent.itemTitle)
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 160
    static let imageHeight: CGFloat = 100
    static let imageRadius: CGFloat = 8
    static let padImageWidth: CGFloat = 240
    static let padImageHeight: CGFloat = 140
    static let padImageRadius: CGFloat = 12
    static let titleLineLimit: Int = 1
}
