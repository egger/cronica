//
//  HomeView.swift
//  Story
//
//  Created by Alexandre Madeira on 10/02/22.
//

import SwiftUI

struct HomeView: View {
    static let tag: Screens? = .home
    @AppStorage("showOnboarding") var displayOnboard = true
    @StateObject private var viewModel: HomeViewModel
    @StateObject private var settings: SettingsStore
    @State private var showSettings = false
    @State private var isLoading = true
    @State private var showConfirmation = false
    @FetchRequest(
        entity: WatchlistItem.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \WatchlistItem.date, ascending: true),
        ],
        predicate: NSCompoundPredicate(type: .and,
                                       subpredicates: [
                                        NSPredicate(format: "schedule == %d", ItemSchedule.soon.toInt),
                                        NSPredicate(format: "notify == %d", true),
                                        NSPredicate(format: "contentType == %d", MediaType.movie.toInt)
                                       ])
    )
    var movies: FetchedResults<WatchlistItem>
    @FetchRequest(
        entity: WatchlistItem.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \WatchlistItem.date, ascending: true),
        ],
        predicate: NSPredicate(format: "upcomingSeason == %d", true)
    )
    var seasons: FetchedResults<WatchlistItem>
    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel())
        _settings = StateObject(wrappedValue: SettingsStore())
    }
    var body: some View {
        ZStack {
            if !viewModel.isLoaded {
                ProgressView()
                    .unredacted()
            }
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    UpcomingSectionsList(items: movies, title: "Upcoming Movies")
                    UpcomingSectionsList(items: seasons, title: "Upcoming Seasons")
                    ItemContentListView(items: viewModel.trending,
                                        title: "Trending",
                                        subtitle: "This week",
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
                .refreshable { viewModel.reload() }
            }
            .navigationDestination(for: ItemContent.self) { item in
                ItemContentView(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
            }
            .navigationDestination(for: Person.self) { person in
                PersonDetailsView(title: person.name, id: person.id)
            }
            .navigationDestination(for: WatchlistItem.self) { item in
                ItemContentView(title: item.itemTitle, id: item.itemId, type: item.itemMedia)
            }
            .redacted(reason: !viewModel.isLoaded ? .placeholder : [] )
            .navigationTitle("Home")
            .toolbar {
                if UIDevice.isIPhone {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showSettings.toggle()
                        }, label: {
                            Label("Settings", systemImage: "gearshape")
                        })
                    }
                }
            }
            .sheet(isPresented: $displayOnboard) {
                WelcomeView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(showSettings: $showSettings)
                    .environmentObject(settings)
            }
            .task {
                await viewModel.load()
            }
            ConfirmationDialogView(showConfirmation: $showConfirmation)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
