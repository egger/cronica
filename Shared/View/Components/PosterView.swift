//
//  PosterView.swift
//  Story
//
//  Created by Alexandre Madeira on 17/01/22.
//

import SwiftUI

struct PosterView: View {
    let title: String
    let url: URL?
    var body: some View {
        AsyncImage(url: url,
                   transaction: Transaction(animation: .easeInOut)) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .transition(.opacity)
            } else if phase.error != nil {
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
            } else {
                ZStack {
                    Rectangle().fill(.thickMaterial)
                    VStack {
                        ProgressView()
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

struct PosterView_Previews: PreviewProvider {
    static var previews: some View {
        PosterView(title: ItemContent.previewContent.itemTitle,
                   url: ItemContent.previewContent.posterImageMedium)
    }
}
