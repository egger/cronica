//
//  CardView.swift
//  Story
//
//  Created by Alexandre Madeira on 15/01/22.
//

import SwiftUI

struct CardView: View {
    let title: String
    let url: URL
    
    var body: some View {
        ZStack {
            ImageView(url: url, title: title)
            TitleView(title: title)
        }
        .contextMenu {
            Button {
                print("watchlist")
            } label: {
                Label("Add to watchlist", systemImage: "bell.square")
            }
            Button {
                print("share")
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
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
        CardView(title: Movie.previewMovie.title, url: Movie.previewMovie.backdropImage)
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

struct ImageView: View {
    let url: URL
    let title: String
    var body: some View {
        ZStack {
            AsyncImage(url: url) { content in
                content
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                EmptyView()
            }
            Rectangle()
                .fill(.black.opacity(0.5))
                .background(.regularMaterial)
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

struct TitleView: View {
    let title: String
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Text(title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(DrawingConstants.lineLimits)
                    .padding()
                Spacer()
            }
            .padding(.horizontal)
        }
        .padding(.horizontal)
    }
}
