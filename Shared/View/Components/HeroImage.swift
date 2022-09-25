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
    var body: some View {
        WebImage(url: url, options: .highPriority)
            .resizable()
            .placeholder {
                placeholder
            }
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
#if os(watchOS)
            Rectangle().fill(.secondary)
#else
            Rectangle().fill(.thickMaterial)
#endif
            VStack {
                Text(title)
                    .lineLimit(1)
                    .padding()
                Image(systemName: "film")
            }
            .padding()
            .foregroundColor(.secondary)
        }
    }
}

struct HeroImage_Previews: PreviewProvider {
    static var previews: some View {
        HeroImage(url: ItemContent.previewContent.cardImageLarge,
                  title: ItemContent.previewContent.itemTitle)
    }
}
