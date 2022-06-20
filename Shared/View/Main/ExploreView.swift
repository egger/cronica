//
//  ExploreView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 30/04/22.
//

import SwiftUI

struct ExploreView: View {
    static let tag: Screens? = .explore
    private let movieGenres: [Genre] = [
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
    private let tvGenres: [Genre] = [
        Genre(id: 10759, name: NSLocalizedString("Action & Adventure", comment: "")),
        Genre(id: 16, name: NSLocalizedString("Animation", comment: "")),
        Genre(id: 35, name: NSLocalizedString("Comedy", comment: "")),
        Genre(id: 80, name: NSLocalizedString("Crime", comment: "")),
        Genre(id: 99, name: NSLocalizedString("Documentary", comment: "")),
        Genre(id: 18, name: NSLocalizedString("Drama", comment: "")),
        Genre(id: 10762, name: NSLocalizedString("Kids", comment: "")),
        Genre(id: 9648, name: NSLocalizedString("Mystery", comment: "")),
        Genre(id: 10765, name: NSLocalizedString("Sci-Fi & Fantasy", comment: ""))
    ]
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section {
                        ForEach(movieGenres.sorted { $0.name! < $1.name! }) { genre in
                            NavigationLink(genre.name!, value: genre)
                        }
                    } header: {
                        Text("Popular Movies by Genre")
                    }
                    Section {
                        ForEach(tvGenres.sorted { $0.name! < $1.name! }) { genre in
                            NavigationLink(genre.name!, value: genre)
                        }
                    } header: {
                        Text("Popular TV Shows by Genre")
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Explore")
            .navigationDestination(for: Genre.self) { genre in
                GenreDetailsView(genre: genre, media: .movie)
            }
            .navigationDestination(for: ItemContent.self) { item in
                ContentDetailsView(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
            }
            .navigationDestination(for: Person.self) { person in
                CastDetailsView(title: person.name, id: person.id)
            }
        }
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
