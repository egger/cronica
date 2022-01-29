//
//  InformationBoxView.swift
//  Story
//
//  Created by Alexandre Madeira on 28/01/22.
//

import SwiftUI

struct InformationBoxView: View {
    let movie: Movie
    var body: some View {
        GroupBox {
            VStack {
                
            }
        } label: {
            Label("Information", systemImage: "info")
                .textCase(.uppercase)
                .foregroundColor(.secondary)
        }
        .padding([.horizontal, .bottom])
    }
}

struct InformationBoxView_Previews: PreviewProvider {
    static var previews: some View {
        InformationBoxView(movie: Movie.previewMovie)
    }
}
