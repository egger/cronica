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
            ImageView(url: url, title: title)
            TitleView(title: title)
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

// The view that handles the image part of CardView.
private struct ImageView: View {
    let url: URL?
    let title: String
    var body: some View {
        ZStack {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                EmptyView()
            }
            Rectangle().fill(.ultraThinMaterial)
            Color.black.opacity(0.8)
            
            AsyncImage(url: url) { content in
                content
                    .resizable()
                    .scaledToFill()
                    .mask {
                        LinearGradient(gradient: Gradient(colors:
                                                            [.black,
                                                             .black.opacity(0)]),
                                       startPoint: .center,
                                       endPoint: .bottom)
                    }
            } placeholder: {
                ProgressView(title)
            }
        }
    }
}

// The view that handles the title portion of CardView.
private struct TitleView: View {
    let title: String
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            HStack {
                Text(title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(DrawingConstants.lineLimits)
                    .padding()
                Spacer()
            }
            .padding(.trailing)
        }
        .padding(.horizontal)
    }
}

private struct DrawingConstants {
    static let cardWidth: CGFloat = 240
    static let cardHeight: CGFloat = 140
    static let cardRadius: CGFloat = 12
    static let shadowOpacity: Double = 0.5
    static let shadowRadius: CGFloat = 5
    static let lineLimits: Int = 1
    static let gradientColor: Color = Color.black
}
