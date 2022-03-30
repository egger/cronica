//
//  InformationView.swift
//  Story
//
//  Created by Alexandre Madeira on 28/01/22.
//

import SwiftUI

struct InformationView: View {
    let item: Content
    var body: some View {
        GroupBox {
            Section {
                SectionView(title: NSLocalizedString("Run Time",
                                                     comment: ""),
                                       content: item.itemRuntime)
                SectionView(title: NSLocalizedString("Release Date:",
                                                     comment: ""),
                                       content: item.theatricalReleaseDate)
                SectionView(title: NSLocalizedString("Status",
                                                     comment: ""),
                                       content: item.itemStatus)
                SectionView(title: NSLocalizedString("Genre",
                                                     comment: ""),
                            content: item.itemGenre)
                SectionView(title: NSLocalizedString("Region of Origin",
                                                     comment: ""),
                            content: item.itemCountry)
                SectionView(title: NSLocalizedString("Production Company",
                                                     comment: ""),
                            content: item.itemCompany)
            }
        } label: {
            Label("Information", systemImage: "info")
        }
        .padding()
    }
}

struct InformationBoxView_Previews: PreviewProvider {
    static var previews: some View {
        InformationView(item: Content.previewContent)
    }
}

private struct SectionView: View {
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
