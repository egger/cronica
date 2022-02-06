//
//  AboutView.swift
//  Story
//
//  Created by Alexandre Madeira on 28/01/22.
//

import SwiftUI

struct AboutView: View {
    let overview: String
    var body: some View {
        GroupBox {
            Text(overview)
                .font(.system(.body, design: .rounded))
                .padding([.top], 2)
                .textSelection(.enabled)
        } label: {
            Label("About", systemImage: "film")
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct OverviewBoxView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView(overview: Movie.previewMovie.overview)
    }
}
