//
//  SeasonButton.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 27/09/22.
//

import SwiftUI

struct SeasonButton: View {
    var numberOfSeasons: [Int]?
    var id: Int
    @Binding var isInWatchlist: Bool
    var body: some View {
        if let numberOfSeasons {
            NavigationLink(destination: SeasonListView(numberOfSeasons: numberOfSeasons, id: id, isInWatchlist: $isInWatchlist), label: {
                Text("Seasons")
            })
            .buttonBorderShape(.capsule)
        }
    }
}
