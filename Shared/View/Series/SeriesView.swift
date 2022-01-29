//
//  SeriesView.swift
//  Story
//
//  Created by Alexandre Madeira on 20/01/22.
//

import SwiftUI

struct SeriesView: View {
    static let tag: String? = "Series"
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    
                }
                .task {
                    //
                }
            }
            .navigationTitle("TV Shows")
        }
        .navigationViewStyle(.stack)
    }
}

struct TvView_Previews: PreviewProvider {
    static var previews: some View {
        SeriesView()
    }
}
