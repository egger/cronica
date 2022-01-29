//
//  OverviewBoxView.swift
//  Story
//
//  Created by Alexandre Madeira on 28/01/22.
//

import SwiftUI

struct OverviewBoxView: View {
    let overview: String
    var body: some View {
        GroupBox {
            Text(overview)
                .font(.system(.body, design: .rounded))
                .padding([.top], 2)
                .textSelection(.enabled)
        } label: {
            Label("Overview", systemImage: "film")
                .textCase(.uppercase)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct OverviewBoxView_Previews: PreviewProvider {
    static var previews: some View {
        OverviewBoxView(overview: Movie.previewMovie.overview)
    }
}
