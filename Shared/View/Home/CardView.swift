//
//  CardView.swift
//  Story
//
//  Created by Alexandre Madeira on 15/01/22.
//

import SwiftUI

struct CardView: View {
    let movie: Movie
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Spacer()
                Text(movie.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(DrawingConstants.lineLimits)
                    .padding()
            }
            Spacer()
        }
        .background {
            ZStack {
                AsyncImage(url: movie.backdropImage) { content in
                    content
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    EmptyView()
                }
                Rectangle()
                    .foregroundColor(.black)
                    .background(.ultraThinMaterial)
                AsyncImage(url: movie.backdropImage) { content in
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
                    ProgressView(movie.title)
                }
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
        CardView(movie: Movie.previewMovie)
    }
}

private struct DrawingConstants {
    static let cardWidth: CGFloat = 300
    static let cardHeight: CGFloat = 200
    static let cardRadius: CGFloat = 12
    static let shadowOpacity: Double = 0.5
    static let shadowRadius: CGFloat = 5
    static let lineLimits: Int = 1
    static let gradientColor: Color = Color.black
}
