//
//  InformationSectionView.swift
//  Story
//
//  Created by Alexandre Madeira on 28/01/22.
//

import SwiftUI

struct InformationSectionView: View {
    let item: ItemContent?
    var body: some View {
        GroupBox {
            Section {
                InfoView(title: NSLocalizedString("Run Time",
                                                  comment: ""),
                         content: item?.itemRuntime)
                InfoView(title: NSLocalizedString("Release Date",
                                                  comment: ""),
                         content: item?.itemTheatricalString)
                InfoView(title: NSLocalizedString("Ratings Score", comment: ""),
                         content: item?.itemRating)
                InfoView(title: NSLocalizedString("Status",
                                                  comment: ""),
                         content: item?.itemStatus.localizedTitle)
                InfoView(title: NSLocalizedString("Genre",
                                                  comment: ""),
                         content: item?.itemGenre)
                InfoView(title: NSLocalizedString("Region of Origin",
                                                  comment: ""),
                         content: item?.itemCountry)
                if let company = item?.productionCompanies?.first {
                    NavigationLink(value: company) {
                        InfoView(title: NSLocalizedString("Production Company",
                                                          comment: ""),
                                 content: company.name)
                    }
                    .buttonStyle(.plain)
                } else {
                    InfoView(title: NSLocalizedString("Production Company",
                                                      comment: ""),
                             content: item?.itemCompany)
                }
            }
        } label: {
            Label("Information", systemImage: "info")
                .unredacted()
        }
    }
}

struct InformationBoxView_Previews: PreviewProvider {
    static var previews: some View {
        InformationSectionView(item: ItemContent.previewContent)
    }
}

private struct InfoView: View {
    let title: String
    let content: String?
    var body: some View {
        if let content {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.caption)
                    Text(content)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .accessibilityElement(children: .combine)
                Spacer()
            }
            .padding([.horizontal, .top], 2)
        }
    }
}
