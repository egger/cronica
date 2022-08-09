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
        GridItem(.adaptive(minimum: UIDevice.isIPad ? 240 : 160 ))
    ]
    var body: some View {
        if let filmography {
            VStack {
                TitleView(title: "Filmography", subtitle: "Know for", image: "list.and.film")
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(filmography) { item in
                        NavigationLink(value: item) {
                            ItemContentFrameView(item: item, showConfirmation: $showConfirmation)
                        }
                        
                    }
                    .buttonStyle(.plain)
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
