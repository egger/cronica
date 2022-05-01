//
//  ExploreView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 30/04/22.
//

import SwiftUI

struct ExploreView: View {
    static let tag: Screens? = .explore
#if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
#endif
    @ViewBuilder
    var body: some View {
#if os(iOS)
        if horizontalSizeClass == .compact {
            NavigationView {
                details
            }
            .navigationViewStyle(.stack)
        } else {
           details
        }
#else
        details
#endif
    }
    
    var details: some View {
        VStack {
            List {
                Section {
                    ForEach(genres.sorted { $0.name! < $1.name! }) { genre in
                        NavigationLink(destination: GenreDetailsView(genreID: genre.id, genreName: genre.name!)) {
                            Text(genre.name!)
                        }
                    }
                } header: {
                    Text("Genres")
                }
            }
        }
        .navigationTitle("Explore")
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}

let genres: [Genre] = [
    Genre(id: 28, name: NSLocalizedString("Action", comment: "")),
    Genre(id: 12, name: NSLocalizedString("Adventure", comment: "")),
    Genre(id: 16, name: NSLocalizedString("Animation", comment: "")),
    Genre(id: 35, name: NSLocalizedString("Comedy", comment: "")),
    Genre(id: 80, name: NSLocalizedString("Crime", comment: "")),
    Genre(id: 99, name: NSLocalizedString("Documentary", comment: "")),
    Genre(id: 18, name: NSLocalizedString("Drama", comment: "")),
    Genre(id: 10751, name: NSLocalizedString("Family", comment: "")),
    Genre(id: 14, name: NSLocalizedString("Fantasy", comment: "")),
    Genre(id: 36, name: NSLocalizedString("History", comment: "")),
    Genre(id: 27, name: NSLocalizedString("Horror", comment: "")),
    Genre(id: 10402, name: NSLocalizedString("Music", comment: "")),
    Genre(id: 9648, name: NSLocalizedString("Mystery", comment: "")),
    Genre(id: 10749, name: NSLocalizedString("Romance", comment: "")),
    Genre(id: 878, name: NSLocalizedString("Science Fiction", comment: "")),
    Genre(id: 53, name: NSLocalizedString("Thriller", comment: "")),
    Genre(id: 10752, name: NSLocalizedString("War", comment: ""))
]
