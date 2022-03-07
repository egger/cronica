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
                if !item.itemRuntime.isEmpty {
                    InformationSectionView(title: NSLocalizedString("Run Time", comment: ""),
                                           content: item.itemRuntime)
                }
                if !item.releaseDateString.isEmpty {
                    InformationSectionView(title: NSLocalizedString("Release Date:", comment: ""),
                                           content: item.releaseDateString)
                }
                if !item.itemStatus.isEmpty {
                    InformationSectionView(title: NSLocalizedString("Status", comment: ""),
                                           content: item.itemStatus)
                }
                if !item.itemGenre.isEmpty {
                    InformationSectionView(title: NSLocalizedString("Genre", comment: ""), content: item.itemGenre)
                }
                if !item.itemCountry.isEmpty {
                    InformationSectionView(title: NSLocalizedString("Region of Origin", comment: ""), content: item.itemCountry)
                }
                if !item.itemProduction.isEmpty {
                    InformationSectionView(title: NSLocalizedString("Production Company", comment: ""), content: item.itemProduction)
                }
            }
        } label: {
            Label("Information", systemImage: "info")
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct InformationBoxView_Previews: PreviewProvider {
    static var previews: some View {
        InformationView(item: Content.previewContent)
    }
}

struct InformationSectionView: View {
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
