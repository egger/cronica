//
//  InformationSectionView.swift
//  Story
//
//  Created by Alexandre Madeira on 28/01/22.
//

import SwiftUI

struct InformationSectionView: View {
    let item: Content
    var body: some View {
        GroupBox {
            Section {
                InfoView(title: NSLocalizedString("Run Time",
                                                     comment: ""),
                                       content: item.itemRuntime)
                InfoView(title: NSLocalizedString("Release Date:",
                                                     comment: ""),
                                       content: item.theatricalReleaseDate)
                InfoView(title: NSLocalizedString("Status",
                                                     comment: ""),
                                       content: item.itemStatus)
                InfoView(title: NSLocalizedString("Genre",
                                                     comment: ""),
                            content: item.itemGenre)
                InfoView(title: NSLocalizedString("Region of Origin",
                                                     comment: ""),
                            content: item.itemCountry)
                InfoView(title: NSLocalizedString("Production Company",
                                                     comment: ""),
                            content: item.itemCompany)
            }
        } label: {
            Label("Information", systemImage: "info")
                .unredacted()
        }
        .padding()
    }
}

struct InformationBoxView_Previews: PreviewProvider {
    static var previews: some View {
        InformationSectionView(item: Content.previewContent)
    }
}

private struct InfoView: View {
    let title: String
    let content: String
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                Text(content)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding([.horizontal, .top], 2)
    }
}
