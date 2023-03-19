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
                    TitleView(title: "Filmography", subtitle: "", image: nil)
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(filmography) { item in
                            Poster(item: item, addedItemConfirmation: $showConfirmation)
                        }
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
