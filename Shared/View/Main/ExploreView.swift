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
                    ForEach(genres) { genre in
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

let genres: [Genre] = [Genre(id: 28, name: "Action"), Genre(id: 12, name: "Adventure"), Genre(id: 16, name: "Animation"), Genre(id: 35, name: "Comedy"), Genre(id: 80, name: "Crime"), Genre(id: 99, name: "Documentary"), Genre(id: 18, name: "Drama"), Genre(id: 10751, name: "Family"), Genre(id: 14, name: "Fantasy"), Genre(id: 36, name: "History"), Genre(id: 27, name: "Horror"), Genre(id: 10402, name: "Music"), Genre(id: 9648, name: "Mystery"), Genre(id: 10749, name: "Romance"), Genre(id: 878, name: "Science Fiction"), Genre(id: 53, name: "Thriller"), Genre(id: 10752, name: "War")]
