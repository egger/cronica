//
//  CardView.swift
//  Story
//
//  Created by Alexandre Madeira on 15/01/22.
//  swiftlint:disable trailing_whitespace

import SwiftUI

struct CardView: View {
    let title: String
    let url: URL?
    var body: some View {
        ZStack {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    ZStack {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                        Rectangle().fill(.ultraThickMaterial)
                        Color.black.opacity(0.6)
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .mask(
                                LinearGradient(gradient: Gradient(stops: [
                                    .init(color: .black, location: 0),
                                    .init(color: .black, location: 0.1),
                                    .init(color: .black.opacity(0), location: 1)
                                ]), startPoint: .center, endPoint: .bottom)
                            )
                    }
                } else if phase.error != nil {
                    Rectangle().fill(.secondary)
                } else {
                    Rectangle().fill(.thickMaterial)
                }
            }
            VStack(alignment: .leading) {
                Spacer()
                HStack {
                    Text(title)
                        .fontWeight(.semibold)
                        .font(.callout)
                        .foregroundColor(.white)
                        .lineLimit(DrawingConstants.lineLimits)
                        .padding()
                    Spacer()
                }
                .padding(.trailing)
            }
            .padding(.horizontal, 2)
        }
        .frame(width: DrawingConstants.cardWidth,
               height: DrawingConstants.cardHeight)
        .cornerRadius(DrawingConstants.cardRadius)
        .shadow(color: .black.opacity(DrawingConstants.shadowOpacity),
                radius: DrawingConstants.shadowRadius)
    }
}

struct BackdropView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(title: Content.previewContent.itemTitle,
                 url: Content.previewContent.cardImageMedium)
    }
}

private struct DrawingConstants {
    static let cardWidth: CGFloat = 240
    static let cardHeight: CGFloat = 140
    static let cardRadius: CGFloat = 12
    static let shadowOpacity: Double = 0.5
    static let shadowRadius: CGFloat = 5
    static let lineLimits: Int = 1
}
