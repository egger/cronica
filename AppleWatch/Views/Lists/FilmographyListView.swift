//
//  FilmographyListView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 13/08/22.
//

import SwiftUI

struct FilmographyListView: View {
    let items: [ItemContent]?
    var body: some View {
        if let items {
            if !items.isEmpty {
                VStack {
                    TitleView(title: "Filmography")
                    LazyVStack {
                        ForEach(items) { item in
                            NavigationLink(value: item) {
								ItemContentRow(item: item)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct FilmographyListView_Previews: PreviewProvider {
    static var previews: some View {
        FilmographyListView(items: ItemContent.examples)
    }
}
