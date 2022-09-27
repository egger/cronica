//
//  EpisodeView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 27/09/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct EpisodeView: View {
    let episode: Episode
    let season: Int
    let show: Int
    var itemLink: URL
    private let persistence = PersistenceController.shared
    @State private var isWatched: Bool = false
    @Binding var isInWatchlist: Bool
    @EnvironmentObject var viewModel: SeasonViewModel
    init(episode: Episode, season: Int, show: Int, isInWatchlist: Binding<Bool>) {
        self.episode = episode
        self.season = season
        self.show = show
        self._isInWatchlist = isInWatchlist
        itemLink = URL(string: "https://www.themoviedb.org/tv/\(show)/season/\(season)/episode/\(episode.episodeNumber ?? 1)")!
    }
    var body: some View {
        HStack {
            WebImage(url: episode.itemImageMedium)
                .placeholder {
                    ZStack {
                        Rectangle().fill(.secondary)
                        Image(systemName: "tv")
                    }
                    .frame(width: 70, height: 45)
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .transition(.fade)
                .frame(width: 70, height: 45)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay {
                    if isWatched {
                        ZStack {
                            Color.black.opacity(0.6)
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.white)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .frame(width: 70, height: 45)
                    }
                }
            VStack(alignment: .leading) {
                Text(episode.itemTitle)
                    .lineLimit(1)
                    .font(.callout)
                Text("Episode \(episode.episodeNumber ?? 0)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button(action: {
                withAnimation {
                    isWatched.toggle()
                }
                persistence.updateEpisodeList(show: self.show, season: self.season, episode: self.episode.id)
            }, label: {
                Label(isWatched ? "Remove from Watched" : "Mark as Watched",
                      systemImage: isWatched ? "minus.circle" : "checkmark.circle")
            })
            .tint(isWatched ? .orange : .green)
        }
        .task {
            isWatched = persistence.isEpisodeSaved(show: show, season: season, episode: episode.id)
        }
    }
}
