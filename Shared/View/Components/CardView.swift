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
    var info: String?
    var subtitle: String?
    var body: some View {
        ZStack {
            AsyncImage(url: url,
                       transaction: Transaction(animation: .easeInOut)) { phase in
                if let image = phase.image {
                    ZStack {
                        Rectangle().fill(.ultraThickMaterial)
                        Color.black.opacity(0.6)
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .mask(
                                LinearGradient(gradient: Gradient(stops: [
                                    .init(color: .black, location: 0),
                                    .init(color: .black, location: 0.5),
                                    .init(color: .black.opacity(0), location: 1)
                                ]), startPoint: .top, endPoint: .bottom)
                            )
                            .transition(.opacity)
                    }
                } else {
                    ZStack {
                        Color.black.opacity(0.4)
                        Rectangle().fill(.thickMaterial)
                        Image(systemName: "film")
                            .foregroundColor(.secondary)
                    }
                }
            }
            if let subtitle = subtitle {
                VStack(alignment: .leading) {
                    Spacer()
                    HStack {
                        Text(title)
                            .fontWeight(.semibold)
                            .font(.callout)
                            .foregroundColor(.white)
                            .lineLimit(DrawingConstants.lineLimits)
                            .padding(.leading)
                        Spacer()
                    }
                    HStack {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.white)
                            .lineLimit(DrawingConstants.lineLimits)
                            .padding(.leading)
                            .padding(.bottom, 8)
                        Spacer()
                    }
                }
                .padding(.horizontal, 2)
            } else {
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
                    
                }
                .padding(.horizontal, 2)
            }
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
    static let cardWidth: CGFloat = 280
    static let cardHeight: CGFloat = 160
    static let cardRadius: CGFloat = 8
    static let shadowOpacity: Double = 0.5
    static let shadowRadius: CGFloat = 2.5
    static let lineLimits: Int = 1
}
