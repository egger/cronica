//
//  HeroImage.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 05/04/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct HeroImage: View {
    let url: URL?
    let title: String
    var blurImage: Bool = false
    var type: MediaType = .movie
    var body: some View {
        WebImage(url: url, options: .highPriority)
            .resizable()
            .placeholder { placeholder }
            .aspectRatio(contentMode: .fill)
            .transition(.opacity)
            .overlay {
                if blurImage {
#if os(watchOS)
                    Rectangle().fill(.secondary)
#else
                    Rectangle().fill(.ultraThinMaterial)
#endif
                    Image(systemName: "eye.slash.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 30))
                }
            }
    }
    private var placeholder: some View {
        ZStack {
            Rectangle().fill(.gray.gradient)
            VStack {
                Text(title)
                    .lineLimit(1)
                    .padding()
                Image(systemName: type == .movie ? "film" : "tv")
                    .font(.title)
            }
            .padding()
            .foregroundColor(.white.opacity(0.8))
        }
    }
}

struct HeroImage_Previews: PreviewProvider {
    static var previews: some View {
        HeroImage(url: ItemContent.example.cardImageLarge,
                  title: ItemContent.example.itemTitle)
    }
}
