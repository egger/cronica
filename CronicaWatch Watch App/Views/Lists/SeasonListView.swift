//
//  SeasonListView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 27/09/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct SeasonListView: View {
    var numberOfSeasons: [Int]
    var id: Int
    @Binding var isInWatchlist: Bool
    var body: some View {
        VStack {
            List {
                ForEach(numberOfSeasons, id: \.self) { season in
                    NavigationLink(
                        destination: EpisodeListView(seasonNumber: season, id: id, inWatchlist: $isInWatchlist),
                        label: {
                            Text("Season \(season)")
                        })
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button(action: {
                            markSeasonAsWatched(season: season)
                        }, label: {
                            Label("Mark season as watched", systemImage: "checkmark.circle.fill")
                        })
                        .tint(.green)
                    }
                }
            }
        }
        .navigationTitle("Seasons")
    }
    
    private func markSeasonAsWatched(season: Int) {
        
    }
}