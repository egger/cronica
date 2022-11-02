//
//  FilmographyListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 13/07/22.
//

import SwiftUI

struct FilmographyListView: View {
    let filmography: [ItemContent]?
    @Binding var showConfirmation: Bool
    let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 160))
    ]
    var body: some View {
        if let filmography {
            if !filmography.isEmpty {
                VStack {
                    TitleView(title: "Filmography", subtitle: "Know for", image: "list.and.film")
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(filmography) { item in
                            PosterView(item: item, addedItemConfirmation: $showConfirmation)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

struct FilmographyListView_Previews: PreviewProvider {
    @State private static var show = false
    static var previews: some View {
        FilmographyListView(filmography: ItemContent.previewContents, showConfirmation: $show)
    }
}
