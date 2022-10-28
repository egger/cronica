//
//  HomeView.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 27/10/22.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @State private var showConfirmation = false
    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel())
    }
    var body: some View {
        ZStack {
            if !viewModel.isLoaded {
                ProgressView()
            }
            VStack {
                ScrollView {
                    ItemContentList(items: viewModel.trending,
                                    title: "Trending",
                                    subtitle: "Today",
                                    image: "crown")
                    ForEach(viewModel.sections) { section in
                        ItemContentList(items: section.results,
                                        title: section.title,
                                        subtitle: section.subtitle,
                                        image: section.image)
                    }
                    AttributionView()
                }
            }
            .navigationDestination(for: ItemContent.self) { item in
                ItemContentDetails(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
            }
            .task {
                await viewModel.load()
            }
            .redacted(reason: !viewModel.isLoaded ? .placeholder : [] )
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
