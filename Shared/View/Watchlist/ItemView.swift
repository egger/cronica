//
//  ItemView.swift
//  Story
//
//  Created by Alexandre Madeira on 19/01/22.
//

import SwiftUI

struct ItemView: View {
    let content: Movie
    var body: some View {
        GroupBox {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
    }
}

struct ItemView_Previews: PreviewProvider {
    static var previews: some View {
        ItemView(content: Movie.previewMovie)
    }
}
