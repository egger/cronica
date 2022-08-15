//
//  HeroImage.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 05/04/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct HeroImage: View {
    let url: URL?
    let title: String
    var blurImage: Bool = false
    private let isPad: Bool = UIDevice.isIPad
    var body: some View {
        ZStack {
            WebImage(url: url)
                .resizable()
                .placeholder {
                    HeroImagePlaceholder(title: title)
                }
                .aspectRatio(contentMode: .fill)
                .transition(.opacity)
            if blurImage {
                Rectangle().fill(.secondary)
                Rectangle().fill(.ultraThinMaterial)
                Image(systemName: "eye.slash.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 30))
            }
        }
        .frame(width: isPad ? DrawingConstants.padImageWidth : DrawingConstants.imageWidth,
               height: isPad ? DrawingConstants.padImageHeight : DrawingConstants.imageHeight)
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
        .shadow(radius: DrawingConstants.shadowRadius)
    }
}

struct HeroImage_Previews: PreviewProvider {
    static var previews: some View {
        HeroImage(url: ItemContent.previewContent.cardImageLarge,
                  title: ItemContent.previewContent.itemTitle)
    }
}

private struct HeroImagePlaceholder: View {
    let title: String
    private let isPad: Bool = UIDevice.isIPad
    var body: some View {
        ZStack {
            Rectangle().fill(.thickMaterial)
            VStack {
                Text(title)
                    .lineLimit(1)
                    .padding(.bottom)
                Image(systemName: "film")
            }
            .padding()
            .foregroundColor(.secondary)
        }
        .frame(width: isPad ? DrawingConstants.padImageWidth : DrawingConstants.imageWidth,
               height: isPad ? DrawingConstants.padImageHeight : DrawingConstants.imageHeight)
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
        .shadow(radius: DrawingConstants.shadowRadius)
    }
}

private struct DrawingConstants {
    static let shadowRadius: CGFloat = 5
    static let imageWidth: CGFloat = 360
    static let imageHeight: CGFloat = 210
    static let imageRadius: CGFloat = 12
    static let padImageWidth: CGFloat = 500
    static let padImageHeight: CGFloat = 300
}
