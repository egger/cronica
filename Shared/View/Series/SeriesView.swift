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
                VStack {
                    
                }
            }
            .navigationTitle("TV Shows")
        }
        #if os(iOS)
        .navigationViewStyle(.stack)
        #endif
    }
}

struct TvView_Previews: PreviewProvider {
    static var previews: some View {
        SeriesView()
    }
}
