//
//  SeasonListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 02/04/22.
//

import SwiftUI

struct SeasonListView: View {
    let title: String
    let id: Int
    let items: [Season]
    var body: some View {
        VStack {
            HStack {
                Text(NSLocalizedString(title, comment: ""))
                    .font(.headline)
                    .padding([.horizontal, .top])
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(items) { item in
                        NavigationLink(destination: SeasonView(id: self.id,
                                                               season: item.seasonNumber,
                                                               title: item.itemTitle)) {
                            PosterView(title: item.itemTitle, url: item.posterImage)
                                .padding([.leading, .trailing], 4)
                        }
                        .buttonStyle(.plain)
                        .padding(.leading, item.id == self.items.first!.id ? 16 : 0)
                        .padding(.trailing, item.id == self.items.last!.id ? 16 : 0)
                        .padding([.top, .bottom])
                    }
                }
            }
        }
    }
}

private struct SeasonView: View {
    var id: Int
    var season: Int
    var title: String
    @StateObject private var viewModel: SeasonViewModel
    @State private var showDetails: Bool = false
    @State private var markAsWatched: Bool = false
    init(id: Int, season: Int, title: String) {
        _viewModel = StateObject(wrappedValue: SeasonViewModel())
        self.id = id
        self.season = season
        self.title = title
    }
    var body: some View {
        ScrollView {
            if let season = viewModel.season {
                VStack {
                    if let items = season.episodes {
                        ForEach(items) { item in
                            NavigationLink(destination: EpisodeDetailsView(item: item)) {
                                EpisodeItemView(item: item)
                                    .contextMenu {
                                        Button(action: {
                                            
                                        }, label: {
                                            Label(markAsWatched ? "Remove from Watched" : "Mark as Watched",
                                                  systemImage: markAsWatched ? "minus.circle" : "checkmark.circle")
                                        })
                                    }
                                    .padding(4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .navigationTitle(title)
            }
        }
        .task { load() }
    }
    
    @Sendable
    private func load() {
        Task {
            await self.viewModel.load(id: self.id, season: self.season)
        }
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 120
    static let imageHeight: CGFloat = 80
    static let imageRadius: CGFloat = 4
    static let textLimit: Int = 1
}

