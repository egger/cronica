//
//  EpisodeDetailsView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 27/09/22.
//

import SwiftUI

struct EpisodeDetailsView: View {
    let episode: Episode
    let season: Int
    let show: Int
    var itemLink: URL
    private let persistence = PersistenceController.shared
    @State var isWatched = false
    init(episode: Episode, season: Int, show: Int) {
        self.episode = episode
        self.season = season
        self.show = show
        itemLink = URL(string: "https://www.themoviedb.org/tv/\(show)/season/\(season)/episode/\(episode.episodeNumber ?? 1)")!
    }
    var body: some View {
        VStack {
            ScrollView {
                HeroImage(url: episode.itemImageMedium,
                          title: episode.itemTitle)
                .clipShape(RoundedRectangle(cornerRadius: 8,
                                            style: .continuous))
                .padding()
                
                watchButton
                    .padding([.bottom, .horizontal])
                
                ShareLink(item: itemLink)
                    .padding([.bottom, .horizontal])
                
                AboutSectionView(about: episode.itemOverview)
                
                CompanionTextView()
                
                AttributionView()
            }
        }
        .navigationTitle(episode.itemTitle)
        .task {
            isWatched = persistence.isEpisodeSaved(show: show, season: season, episode: episode.id)
        }
    }
    
    private var watchButton: some View {
        Button(action: {
            withAnimation {
                isWatched.toggle()
            }
            persistence.updateEpisodeList(show: self.show, season: self.season, episode: self.episode.id)
        }, label: {
            Label(isWatched ? "Remove from Watched" : "Mark as Watched",
                  systemImage: isWatched ? "minus.circle" : "checkmark.circle")
        })
        .buttonStyle(.borderedProminent)
        .tint(isWatched ? .orange : .green)
    }
}
