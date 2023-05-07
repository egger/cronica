//
//  PosterPlaceholder.swift
//  Story
//
//  Created by Alexandre Madeira on 07/05/23.
//

import SwiftUI

struct PosterPlaceholder: View {
    var title: String
    let type: MediaType
    @StateObject private var settings = SettingsStore.shared
    var body: some View {
        ZStack {
            Rectangle().fill(.gray.gradient)
            VStack {
                if settings.isCompactUI {
                    Image(systemName: type == .tvShow ? "tv" : "film")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                } else {
                    Text(title)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                        .padding()
                    Image(systemName: type == .tvShow ? "tv" : "film")
                        .font(.title)
                        .foregroundColor(.white.opacity(0.8))
                }
                
            }
            .padding()
        }
        .frame(width: settings.isCompactUI ? DrawingConstants.compactPosterWidth : DrawingConstants.posterWidth,
               height: settings.isCompactUI ? DrawingConstants.compactPosterHeight : DrawingConstants.posterHeight)
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.posterRadius,
                                    style: .continuous))
        .shadow(radius: DrawingConstants.shadowRadius)
    }
}

private struct DrawingConstants {
#if os(tvOS)
    static let posterWidth: CGFloat = 260
    static let posterHeight: CGFloat = 380
    static let posterRadius: CGFloat = 12
#else
    static let posterWidth: CGFloat = 160
    static let posterHeight: CGFloat = 240
    static let posterRadius: CGFloat = 8
#endif
    static let compactPosterWidth: CGFloat = 80
    static let compactPosterRadius: CGFloat = 4
    static let compactPosterHeight: CGFloat = 140
    static let shadowRadius: CGFloat = 2
}

struct PosterPlaceholder_Previews: PreviewProvider {
    static var previews: some View {
        PosterPlaceholder(title: "Preview", type: .movie)
    }
}
