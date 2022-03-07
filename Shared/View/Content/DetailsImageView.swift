//
//  DetailsImageView.swift
//  Story
//
//  Created by Alexandre Madeira on 28/01/22.
//

import SwiftUI

// This view handles the hero image for DetailsView.
struct DetailsImageView: View {
    let url: URL?
    let title: String
    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            ZStack {
                Rectangle()
                    .fill(.secondary)
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

struct MovieImageView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsImageView(url: Content.previewContent.cardImage,
                         title: Content.previewContent.itemTitle)
    }
}

private struct DrawingConstants {
    static let shadowOpacity: Double = 0.5
    static let shadowRadius: CGFloat = 5
    static let imageWidth: CGFloat = 360
    static let imageHeight: CGFloat = 220
    static let imageRadius: CGFloat = 12
}
