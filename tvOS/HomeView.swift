//
//  HomeView.swift
//  Story (tvOS)
//
//  Created by Alexandre Madeira on 13/03/22.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel())
    }
    var body: some View {
        ScrollView {
            ForEach(viewModel.moviesSections) {
                CardListView(style: $0.style, type: MediaType.movie, title: $0.title, items: $0.results)
            }
            ForEach(viewModel.tvSections) {
                CardListView(style: $0.style, type: MediaType.tvShow, title: $0.title, items: $0.results)
            }
            AttributionView()
        }.task {
            load()
        }
    }
    
    @Sendable
    private func load() {
        Task {
            await viewModel.loadSections()
        }
    }
}

//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView()
//    }
//}
