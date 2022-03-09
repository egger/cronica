//
//  HeroImageView.swift
//  Story
//
//  Created by Alexandre Madeira on 07/03/22.
//

import SwiftUI

struct HeroImageView: View {
    let title: String
    let url: URL?
    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            ZStack {
                Color.secondary
                ProgressView(title)
            }
        }
        .frame(width: DrawingConstants.imageWidth,
               height: DrawingConstants.imageHeight)
        .cornerRadius(DrawingConstants.imageRadius)
        .shadow(color: .black.opacity(DrawingConstants.shadowOpacity),
                radius: DrawingConstants.shadowRadius)
        .padding([.top, .bottom])
    }
}

struct HeroImageView_Previews: PreviewProvider {
    static var previews: some View {
        HeroImageView(title: Content.previewContent.itemTitle,
                      url: Content.previewContent.cardImageMedium)
    }
}

private struct DrawingConstants {
    static let shadowOpacity: Double = 0.2
    static let shadowRadius: CGFloat = 5
    static let imageWidth: CGFloat = 360
    static let imageHeight: CGFloat = 220
    static let imageRadius: CGFloat = 12
}
