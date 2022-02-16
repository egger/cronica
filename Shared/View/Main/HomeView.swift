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
    @StateObject private var tvShows = TVViewModel()
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    HomeListItemsView()
                    ForEach(movies.sections) {
                        MovieListView(style: $0.style, title: $0.title, movies: $0.results)
                    }
                    ForEach(tvShows.sections) {
                        TVListView(style: $0.style, title: $0.title, series: $0.results)
                    }
                }
                .navigationTitle("Home")
                .task {
                    loadMovies()
                    loadTV()
                }
            }
        }
    }
    
    @Sendable
    private func loadMovies() {
        Task {
            await movies.loadAllEndpoints()
        }
    }
    
    @Sendable
    private func loadTV() {
        Task {
            await tvShows.loadAllEndpoints()
        }
    }
}

//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView()
//    }
//}
