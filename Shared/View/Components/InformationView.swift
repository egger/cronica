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
                InformationSectionView(title: "Run Time", content: item.itemRuntime)
                InformationSectionView(title: "Release Date:", content: item.releaseDateString)
                InformationSectionView(title: "Status", content: item.itemStatus)
                InformationSectionView(title: "Genre", content: item.itemGenre)
                InformationSectionView(title: "Region of Origin", content: item.itemCountry)
                InformationSectionView(title: "Production Company", content: item.itemProduction)
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
