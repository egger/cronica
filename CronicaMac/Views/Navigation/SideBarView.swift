//
//  SideBarView.swift
//  CronicaMac
//
//  Created by Alexandre Madeira on 02/11/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct SideBarView: View {
    @AppStorage("selectedView") private var selectedView: Screens = .home
    @State private var showNotifications = false
    @StateObject private var searchViewModel = SearchViewModel()
    @State private var showConfirmation = false
    @State private var selectedSearchItem: ItemContent? = nil
    @State private var scope: SearchItemsScope = .noScope
    let persistence = PersistenceController.shared
    @State private var isSearching = false
    let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 160))
    ]
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedView) {
                NavigationLink(value: Screens.home) {
                    Label("Home", systemImage: "house")
                }
                
                NavigationLink(value: Screens.discover) {
                    Label("Explore", systemImage: "film")
                }
                
                NavigationLink(value: Screens.watchlist) {
                    Label("Watchlist", systemImage: "square.stack.fill")
                }
                .dropDestination(for: ItemContent.self) { items, _  in
                    for item in items {
                        Task {
                            let content = try? await NetworkService.shared.fetchItem(id: item.id, type: item.itemContentMedia)
                            guard let content else { return }
                            PersistenceController.shared.save(content)
                        }
                    }
                    return true
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
                        placement: .sidebar)
            .disableAutocorrection(true)
            .searchScopes($scope) {
                ForEach(SearchItemsScope.allCases) { scope in
                    Text(scope.localizableTitle).tag(scope)
                }
            }
            .navigationTitle("Cronica")
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
                    case .discover:
                        DiscoverView()
                    case .watchlist:
                        WatchlistView()
                            .environment(\.managedObjectContext, persistence.container.viewContext)
                    }
                }
                
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
    
    @ViewBuilder
    private var search: some View {
        switch searchViewModel.stage {
        case .none: EmptyView()
        case .searching:
            ZStack {
                Rectangle()
                    .fill(.regularMaterial)
                    .ignoresSafeArea(.all)
                ProgressView("Searching")
                    .foregroundColor(.secondary)
                    .padding()
            }
        case .empty:
            ZStack {
                Rectangle()
                    .fill(.regularMaterial)
                    .ignoresSafeArea(.all)
                Label("No Results", systemImage: "minus.magnifyingglass")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
        case .failure:
            ZStack {
                Rectangle()
                    .fill(.regularMaterial)
                    .ignoresSafeArea(.all)
                Label("Search failed, try again later.", systemImage: "text.magnifyingglass")
            }
        case .success:
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        VStack {
                            LazyVGrid(columns: columns, spacing: 20) {
                                switch scope {
                                case .noScope:
                                    ForEach(searchViewModel.items) { item in
                                        PosterView(item: item, addedItemConfirmation: $showConfirmation)
                                            .onTapGesture {
                                                selectedSearchItem = item
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
                                case .movies:
                                    ForEach(searchViewModel.items.filter { $0.itemContentMedia == .movie }) { item in
                                        PosterView(item: item, addedItemConfirmation: $showConfirmation)
                                            .onTapGesture {
                                                selectedSearchItem = item
                                            }
                                    }
                                case .shows:
                                    ForEach(searchViewModel.items.filter { $0.itemContentMedia == .movie }) { item in
                                        PosterView(item: item, addedItemConfirmation: $showConfirmation)
                                            .onTapGesture {
                                                selectedSearchItem = item
                                            }
                                    }
                                case .people:
                                    ForEach(searchViewModel.items.filter { $0.itemContentMedia == .movie }) { item in
                                        PosterView(item: item, addedItemConfirmation: $showConfirmation)
                                            .onTapGesture {
                                                selectedSearchItem = item
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

struct SideBarView_Previews: PreviewProvider {
    static var previews: some View {
        SideBarView()
    }
}
