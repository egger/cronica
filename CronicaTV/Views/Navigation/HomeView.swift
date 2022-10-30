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
                    PinItemsList()
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

private struct PinItemsList: View {
    @FetchRequest(
        entity: WatchlistItem.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \WatchlistItem.date, ascending: true),
        ],
        predicate: NSPredicate(format: "isPin == %d", true)
    )
    
    var items: FetchedResults<WatchlistItem>
    var body: some View {
        WatchlistItemListView(items: items.filter { $0.largeCardImage != nil },
                              title: "My Pins", subtitle: "Pinned Items",
                              image: "pin")
    }
}
