//
//  InformationSectionView.swift
//  Story
//
//  Created by Alexandre Madeira on 28/01/22.
//

import SwiftUI

struct InformationSectionView: View {
    let item: Content?
    var body: some View {
        GroupBox {
            Section {
                if let runtime = item?.itemRuntime {
                    InfoView(title: NSLocalizedString("Run Time",
                                                         comment: ""),
                                           content: runtime)
                }
                if let date = item?.itemTheatricalString {
                    InfoView(title: NSLocalizedString("Release Date",
                                                         comment: ""),
                                           content: date)
                }
                if let status = item?.itemStatus {
                    InfoView(title: NSLocalizedString("Status",
                                                         comment: ""),
                             content: status.scheduleTitle)
                }
                if let genre = item?.itemGenre {
                    InfoView(title: NSLocalizedString("Genre",
                                                         comment: ""),
                                content: genre)
                }
                if let country = item?.itemCountry {
                    InfoView(title: NSLocalizedString("Region of Origin",
                                                         comment: ""),
                                content: country)
                }
                if let company = item?.itemCompany {
                    InfoView(title: NSLocalizedString("Production Company",
                                                         comment: ""),
                                content: company)
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
