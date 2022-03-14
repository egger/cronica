//
//  CardView.swift
//  Story (tvOS)
//
//  Created by Alexandre Madeira on 13/03/22.
//

import SwiftUI

struct CardView: View {
    let title: String
    let url: URL?
    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            Color.secondary
        }
        .ignoresSafeArea(.all)
        .frame(width: DrawingConstants.cardWidth,
               height: DrawingConstants.cardHeight)
        .cornerRadius(DrawingConstants.cardRadius)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(title: Content.previewContent.itemTitle, url: Content.previewContent.cardImageMedium)
    }
}

private struct DrawingConstants {
    static let cardWidth: CGFloat = 380
    static let cardHeight: CGFloat = 240
    static let cardRadius: CGFloat = 12
}
