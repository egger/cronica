//
//  InformationSectionView.swift
//  Story
//
//  Created by Alexandre Madeira on 28/01/22.
//

import SwiftUI
#if os(iOS) || os(macOS)
struct InformationSectionView: View {
    let item: ItemContent?
    let type: MediaType
    var body: some View {
        GroupBox {
            Section {
                InfoView(title: NSLocalizedString("Original Title",
                                                  comment: ""),
                         content: item?.originalItemTitle)
                if let numberOfSeasons = item?.numberOfSeasons, let numberOfEpisodes = item?.numberOfEpisodes {
                    InfoView(title: NSLocalizedString("Overview",
                                                      comment: ""),
                             content: "\(numberOfSeasons) Seasons • \(numberOfEpisodes) Episodes")
                }
                InfoView(title: NSLocalizedString("Run Time",
                                                  comment: ""),
                         content: item?.itemRuntime)
                if type == .movie {
                    InfoView(title: NSLocalizedString("Release Date",
                                                      comment: ""),
                             content: item?.itemTheatricalString)
                } else {
                    InfoView(title: NSLocalizedString("First Air Date",
                                                      comment: ""),
                             content: item?.itemFirstAirDate)
                }
                InfoView(title: NSLocalizedString("Ratings Score", comment: ""),
                         content: item?.itemRating)
                InfoView(title: NSLocalizedString("Status",
                                                  comment: ""),
                         content: item?.itemStatus.localizedTitle)
                InfoView(title: NSLocalizedString("Genres", comment: ""),
                         content: item?.itemGenres)
                InfoView(title: NSLocalizedString("Region of Origin",
                                                  comment: ""),
                         content: item?.itemCountry)
                if let companies = item?.itemCompanies, let company = companies.first {
                    if !companies.isEmpty {
                        NavigationLink(value: companies) {
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("Production Company")
                                            .font(.caption)
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                    }
                                    Text(company.name)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .accessibilityElement(children: .combine)
                                Spacer()
                            }
                            .padding([.horizontal, .top], 2)
                        }
#if os(macOS)
                        .buttonStyle(.link)
#endif
                    }
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
        #if os(iOS)
        .groupBoxStyle(TransparentGroupBox())
        #endif
    }
}


struct InformationBoxView_Previews: PreviewProvider {
    static var previews: some View {
        InformationSectionView(item: ItemContent.example, type: .movie)
    }
}
#endif

struct InfoView: View {
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
