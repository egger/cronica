//
//  HomeView.swift
//  CronicaMac
//
//  Created by Alexandre Madeira on 02/11/22.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showConfirmation = false
    var body: some View {
        NavigationStack {
            ZStack {
                if !viewModel.isLoaded {
                    ProgressView("Loading")
                }
                VStack {
                    ScrollView {
                        //UpcomingWatchlist()
                        ItemContentListView(items: viewModel.trending,
                                            title: "Trending",
                                            subtitle: "Today",
                                            image: "crown",
                                            addedItemConfirmation: $showConfirmation)
                        ForEach(viewModel.sections) { section in
                            ItemContentListView(items: section.results,
                                                title: section.title,
                                                subtitle: section.subtitle,
                                                image: section.image,
                                                addedItemConfirmation: $showConfirmation)
                        }
                        AttributionView()
                    }
                }
                .redacted(reason: viewModel.isLoaded ? [] : .placeholder)
                .navigationDestination(for: ItemContent.self) { item in
                    ItemContentDetailsView(id: item.id, title: item.itemTitle, type: item.itemContentMedia)
                }
                .navigationTitle("Home")
                .task {
                    await viewModel.load()
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

private struct UpcomingWatchlist: View {
    @FetchRequest(
        entity: WatchlistItem.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \WatchlistItem.date, ascending: true),
        ],
        predicate: NSCompoundPredicate(type: .or, subpredicates: [
                                        NSCompoundPredicate(type: .and,
                                                            subpredicates: [
                                                                NSPredicate(format: "schedule == %d", ItemSchedule.soon.toInt),
                                                                NSPredicate(format: "notify == %d", true),
                                                                NSPredicate(format: "contentType == %d", MediaType.movie.toInt)
                                                            ])
                                        ,
                                        NSPredicate(format: "upcomingSeason == %d", true)])
    )
    var items: FetchedResults<WatchlistItem>
    var body: some View {
        UpcomingListView(items: items.filter { $0.image != nil })
    }
}
