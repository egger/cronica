//
//  SwiftUIView.swift
//  Story
//
//  Created by Alexandre Madeira on 07/02/22.
//

import SwiftUI

struct ItemView: View {
    let title: String
    let image: URL
    let type: String
    var body: some View {
        HStack {
            AsyncImage(url: image) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } placeholder: {
                ProgressView()
            }
            VStack(alignment: .leading) {
                HStack {
                    Text(title)
                        .lineLimit(1)
                }
                HStack {
                    Text(type)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
    }
}

struct ItemView_Previews: PreviewProvider {
    static var previews: some View {
        ItemView(title: Movie.previewMovie.title, image: Movie.previewMovie.backdropImage, type: "Movie")
    }
}
