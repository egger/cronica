//
//  PosterPlaceholder.swift
//  Cronica
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
                    Image(systemName: "popcorn.fill")
                        .font(.title3)
                        .fontWidth(.expanded)
                        .foregroundColor(.white.opacity(0.8))
                        .padding()
                } else {
                    Image(systemName: "popcorn.fill")
                        .font(.title)
                        .fontWidth(.expanded)
                        .foregroundColor(.white.opacity(0.8))
                        .padding()
                    Text(title)
                        .font(.callout)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                        .padding(.bottom)
                        .padding(.horizontal, 4)
                }
                
            }
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
#else
    static let posterWidth: CGFloat = 160
    static let posterHeight: CGFloat = 240
#endif
    static let posterRadius: CGFloat = 12
    static let compactPosterWidth: CGFloat = 80
    static let compactPosterRadius: CGFloat = 4
    static let compactPosterHeight: CGFloat = 140
    static let shadowRadius: CGFloat = 2
}

#Preview {
    PosterPlaceholder(title: "Preview", type: .movie)
}
