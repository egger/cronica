//
//  InfoSection.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 28/10/22.
//

import SwiftUI

struct InfoSection: View {
    var item: ItemContent?
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Label("Information", systemImage: "info")
                    .unredacted()
                Spacer()
            }
            .padding(.bottom)
            HStack {
                Section {
                    InfoSegmentView(title: NSLocalizedString("Run Time",
                                                             comment: ""),
                                    info: item?.itemRuntime)
                    InfoSegmentView(title: NSLocalizedString("Release Date",
                                                             comment: ""),
                                    info: item?.itemTheatricalString)
                    InfoSegmentView(title: NSLocalizedString("Ratings Score", comment: ""),
                                    info: item?.itemRating)
                    InfoSegmentView(title: NSLocalizedString("Status",
                                                             comment: ""),
                                    info: item?.itemStatus.localizedTitle)
                    InfoSegmentView(title: NSLocalizedString("Genre",
                                                             comment: ""),
                                    info: item?.itemGenre)
                    InfoSegmentView(title: NSLocalizedString("Region of Origin",
                                                             comment: ""),
                                    info: item?.itemCountry)
                    InfoSegmentView(title: NSLocalizedString("Production Company",
                                                             comment: ""),
                                    info: item?.itemCompany)
                }
            }
        }
        .padding()
    }
}

private struct InfoSegmentView: View {
    let title: String
    let info: String?
    var body: some View {
        if let info {
            VStack {
                Text(title)
                    .lineLimit(1)
                    .font(.body)
                    .foregroundColor(.secondary)
                Text(info)
                    .lineLimit(1)
                    .font(.body)
            }
        }
    }
}
