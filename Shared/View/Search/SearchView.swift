//
//  SearchView.swift
//  Story
//
//  Created by Alexandre Madeira on 14/01/22.
//

import SwiftUI

struct SearchView: View {
    static let tag: String? = "Search"
    var body: some View {
        NavigationView {
            VStack {
                Text("Search")
            }
            .navigationTitle("Search")
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
