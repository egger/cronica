//
//  HeroImage.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 05/04/22.
//

import SwiftUI

struct HeroImage: View {
    let url: URL?
    let title: String
    var blurImage: Bool = false
    var body: some View {
        AsyncImage(url: url,
                   transaction: Transaction(animation: .easeInOut)) { phase in
            if let image = phase.image {
                ZStack {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .transition(.opacity)
                    if blurImage {
                        Rectangle().fill(.ultraThickMaterial)
                        Image(systemName: "eye.slash.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 30))
                    }
                }
            } else if phase.error != nil {
                ZStack {
                    Rectangle().fill(.thickMaterial)
                    ProgressView(title)
                }
            } else {
                ZStack {
                    Rectangle().fill(.thickMaterial)
                    VStack {
                        Text(title)
                            .lineLimit(1)
                            .padding(.bottom)
                        Image(systemName: "film")
                    }
                    .padding()
                    .foregroundColor(.secondary)
                }
            }
        }
                   
    }
}

struct HeroImage_Previews: PreviewProvider {
    static var previews: some View {
        HeroImage(url: ItemContent.previewContent.cardImageLarge,
                  title: ItemContent.previewContent.itemTitle)
    }
}
