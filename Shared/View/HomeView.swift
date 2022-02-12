//
//  HomeView.swift
//  Story
//
//  Created by Alexandre Madeira on 10/02/22.
//

import SwiftUI

struct HomeView: View {
    static let tag: String? = "Home"
    @StateObject private var movies = MovieViewModel()
    @StateObject private var tvShows = SeriesViewModel()
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ForEach(movies.sections) {
                        MovieListView(style: $0.style, title: $0.title, movies: $0.results)
                    }
                    ForEach(tvShows.sections) {
                        TvListView(style: $0.style, title: $0.title, series: $0.results)
                    }
                }
                .navigationTitle("Home")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            
                        } label: {
                            Image(systemName: "person.circle")
                        }
                        .controlSize(.large)
                    }
                }
                .task {
                    load()
                }
            }
        }
    }
    
    @Sendable
    private func load() {
        Task {
            await movies.loadAllEndpoints()
            await tvShows.loadAllEndpoints()
        }
    }
}

//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView()
//    }
//}
