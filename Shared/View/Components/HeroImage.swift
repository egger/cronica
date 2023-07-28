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
    var type: MediaType = .movie
    var body: some View {
        WebImage(url: url, options: .highPriority)
            .resizable()
            .placeholder { placeholder }
            .aspectRatio(contentMode: .fill)
            .transition(.opacity)
    }
    private var placeholder: some View {
        ZStack {
            Rectangle().fill(.gray.gradient)
            Image(systemName: "popcorn.fill")
                .font(.title)
                .fontWidth(.expanded)
                .foregroundColor(.white.opacity(0.8))
                .padding()
        }
    }
}

struct HeroImage_Previews: PreviewProvider {
    static var previews: some View {
        HeroImage(url: ItemContent.example.cardImageLarge,
                  title: ItemContent.example.itemTitle)
    }
}
