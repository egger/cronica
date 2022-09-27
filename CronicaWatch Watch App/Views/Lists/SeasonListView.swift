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
                }
            }
        }
        .navigationTitle("Seasons")
    }
}
