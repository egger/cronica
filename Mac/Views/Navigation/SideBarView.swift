//
//  SideBarView.swift
//  CronicaMac
//
//  Created by Alexandre Madeira on 02/11/22.
//

import SwiftUI

struct SideBarView: View {
    @Environment(\.managedObjectContext) var viewContext
    @AppStorage("selectedView") private var selectedView: Screens = .home
    @State private var showNotifications = false
    @StateObject private var searchViewModel = SearchViewModel()
    @State private var showConfirmation = false
    let persistence = PersistenceController.shared
    @State private var isSearching = false
    let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 160))
    ]
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedView) {
                Section {
                    NavigationLink(value: Screens.home) {
                        Label("Home", systemImage: "house")
                    }

                    NavigationLink(value: Screens.explore) {
                        Label("Explore", systemImage: "film")
                    }
                    NavigationLink(value: Screens.watchlist) {
                        Label("Watchlist", systemImage: "square.stack.fill")
                    }
                }

            }
            .task(id: searchViewModel.query) {
                if !searchViewModel.query.isEmpty {
                    isSearching = true
                } else {
                    isSearching = false
                }
                await searchViewModel.search(searchViewModel.query)
            }
            .searchable(text: $searchViewModel.query,
                        placement: .toolbar)
            .disableAutocorrection(true)
        } detail: {
            ZStack {
                if isSearching {
                    search
                } else {
                    switch selectedView {
                    case .home:
                        NavigationStack {
                            HomeView()
                                .environment(\.managedObjectContext, persistence.container.viewContext)
                        }
                    case .explore:
                        NavigationStack {
                            ExploreView()
                        }
                        //DiscoverView()
                    case .watchlist:
                        WatchlistView()
                            .environment(\.managedObjectContext, persistence.container.viewContext)
                    }
                }
                ConfirmationDialogView(showConfirmation: $showConfirmation)
            }
        }
        .navigationSplitViewStyle(.balanced)
    }

    @ViewBuilder
    private var search: some View {
        switch searchViewModel.stage {
        case .none: EmptyView()
        case .searching:
            NavigationStack {
                VStack {
                    ProgressView("Searching")
                        .foregroundColor(.secondary)
                        .padding()
                }
                .background {
                    Rectangle()
                        .fill(.regularMaterial)
                        .ignoresSafeArea(.all)
                }
                .navigationTitle("Search")
            }
        case .empty:
            NavigationStack {
                VStack {
                    Label("No Results", systemImage: "minus.magnifyingglass")
                        .font(.title)
                        .foregroundColor(.secondary)
                }
                .background {
                    Rectangle()
                        .fill(.regularMaterial)
                        .ignoresSafeArea(.all)
                }
                .navigationTitle("Search")
            }
        case .failure:
            NavigationStack {
                VStack {
                    Label("Search failed, try again later.", systemImage: "text.magnifyingglass")
                        .font(.title)
                        .foregroundColor(.secondary)
                }
                .background {
                    Rectangle()
                        .fill(.regularMaterial)
                        .ignoresSafeArea(.all)
                }
                .navigationTitle("Search")
            }
        case .success:
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        VStack {
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(searchViewModel.items) { item in
                                    if item.media == .person {
                                        PersonSearchImage(item: item)
                                    } else {
                                        Poster(item: item, addedItemConfirmation: $showConfirmation)
                                    }
                                }
                                .buttonStyle(.plain)
                                if searchViewModel.startPagination && !searchViewModel.endPagination {
                                    CenterHorizontalView {
                                        ProgressView()
                                            .padding()
                                            .onAppear {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                    withAnimation {
                                                        searchViewModel.loadMoreItems()
                                                    }
                                                }
                                            }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .navigationDestination(for: ItemContent.self) { item in
                        if item.media == .person {
                            PersonDetailsView(title: item.itemTitle, id: item.id)
                        } else {
                            ItemContentDetailsView(id: item.id, title: item.itemTitle, type: item.itemContentMedia)
                        }
                    }
                }
                .navigationTitle("Search")
            }
        }
    }
}

