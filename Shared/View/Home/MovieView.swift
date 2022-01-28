//
//  HomeView.swift
//  Story
//
//  Created by Alexandre Madeira on 16/01/22.
//

import SwiftUI

struct MovieView: View {
    @StateObject private var viewModel = MovieViewModel()
    static let tag: String? = "Movie"
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.sections) {
                        HorizontalListView(sectionStyle: $0.thumbnailType,
                                           sectionTitle: $0.title,
                                           items: $0.movies)
                    }
                }
                .task {
                    loadSections()
                }
            }
            .navigationTitle("Movies")
        }
        .navigationViewStyle(.stack)
    }
    
    @Sendable
    private func loadSections() {
        Task {
            await viewModel.loadAllEndpoints()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        MovieView()
    }
}
