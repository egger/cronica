//
//  InformationView.swift
//  Story
//
//  Created by Alexandre Madeira on 28/01/22.
//

import SwiftUI

struct InformationView: View {
    let movie: Movie
    var body: some View {
        GroupBox {
            VStack {
                InformationSectionView(title: "Run Time", content: movie.movieRuntime)
                InformationSectionView(title: "Release Date:", content: movie.release)
                InformationSectionView(title: "Status", content: movie.status ?? "")
            }
        } label: {
            Label("Information", systemImage: "info")
                .textCase(.uppercase)
                .foregroundColor(.secondary)
        }
        .padding([.horizontal, .bottom])
    }
}

struct InformationBoxView_Previews: PreviewProvider {
    static var previews: some View {
        InformationView(movie: Movie.previewMovie)
    }
}

struct InformationSectionView: View {
    let title: String
    let content: String
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                Text(content)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding([.horizontal, .top], 2)
    }
}
