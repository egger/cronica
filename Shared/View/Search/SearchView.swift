//
//  SearchView.swift
//  Story
//
//  Created by Alexandre Madeira on 14/01/22.
//

import SwiftUI

struct SearchView: View {
    static let tag: String? = "Search"
    @State private var searchString: String = ""
    var body: some View {
        NavigationView {
            VStack {
                Text("Search WIP")
            }
            .navigationTitle("Search")
            .searchable(text: $searchString, placement: .navigationBarDrawer)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
