//
//  OverviewBoxView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 25/04/22.
//

import SwiftUI

struct OverviewBoxView: View {
    let overview: String?
    let type: MediaType
    var body: some View {
        GroupBox {
            Text(overview ?? "No Information Available.")
                .padding([.top], 2)
                .lineLimit(4)
        } label: {
            switch type {
            case .movie:
                Label("About", systemImage: "film")
                    .unredacted()
            case .person:
                Label("Biography", systemImage: "book")
                    .unredacted()
            case .tvShow:
                Label("About", systemImage: "film")
                    .unredacted()
            }
        }
    }
}

struct OverviewBoxView_Previews: PreviewProvider {
    static var previews: some View {
        OverviewBoxView(overview: Content.previewContent.overview, type: .movie)
    }
}
