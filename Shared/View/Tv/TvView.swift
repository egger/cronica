//
//  TvView.swift
//  Story
//
//  Created by Alexandre Madeira on 20/01/22.
//

import SwiftUI

struct TvView: View {
    static let tag: String? = "Tv"
    var body: some View {
        ScrollView {
            VStack {
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            }
            .navigationTitle("TV")
        }
    }
}

struct TvView_Previews: PreviewProvider {
    static var previews: some View {
        TvView()
    }
}
