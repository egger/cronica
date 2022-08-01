//
//  SideBarView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 28/04/22.
//

import SwiftUI

struct SideBarView: View {
    @SceneStorage("selectedView") var selectedView: Screens?
    @StateObject private var settings: SettingsStore
    @StateObject private var viewModel: SearchViewModel
    @State private var showSettings = false
    @State private var selectedSearchItem: ItemContent? = nil
    init() {
        _settings = StateObject(wrappedValue: SettingsStore())
        _viewModel = StateObject(wrappedValue: SearchViewModel())
    }
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedView) {
                NavigationLink(value: Screens.home) {
                    Label("Home", systemImage: "house")
                }
                .tag(HomeView.tag)
                NavigationLink(value: Screens.discover) {
                    Label("Explore", systemImage: "film")
                }
                .tag(DiscoverView.tag)
                NavigationLink(value: Screens.watchlist) {
                    Label("Watchlist", systemImage: "square.stack.fill")
                }
                .tag(WatchlistView.tag)
            }
            .listStyle(.sidebar)
            .navigationTitle("Cronica")
            .searchable(text: $viewModel.query, placement: .sidebar, prompt: "Movies, Shows, People")
            .disableAutocorrection(true)
            .searchSuggestions {
                ForEach(viewModel.searchSuggestions) { item in
                    Text(item.suggestion).searchCompletion(item.suggestion)
                }
            }
            .onAppear {
                viewModel.observe()
                Task {
                    await viewModel.fetchSuggestions()
                }
            }
            .overlay(searchOverlay)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        HapticManager.shared.softHaptic()
                        showSettings.toggle()
                    }, label: {
                        Label("Settings", systemImage: "gearshape")
                    })
                }
            }
        } detail: {
            NavigationStack {
                VStack {
                    switch selectedView {
                    case .discover: DiscoverView()
                    case .watchlist: WatchlistView()
                    default: HomeView()
                    }
                }
                .navigationDestination(for: Screens.self) { screens in
                    switch screens {
                    case .home: HomeView()
                    case .discover: DiscoverView()
                    case .watchlist: WatchlistView()
                    case .search: SearchView()
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(showSettings: $showSettings)
                    .environmentObject(settings)
            }
            .sheet(item: $selectedSearchItem) { item in
                if item.media == .person {
                    NavigationStack {
                        PersonDetailsView(title: item.itemTitle, id: item.id)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button("Done") {
                                        selectedSearchItem = nil
                                    }
                                }
                            }
                            .navigationDestination(for: ItemContent.self) { item in
                                ItemContentView(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
                            }
                            .navigationDestination(for: Person.self) { person in
                                PersonDetailsView(title: person.name, id: person.id)
                            }
                    }
                } else {
                    NavigationStack {
                        ItemContentView(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button("Done") {
                                        selectedSearchItem = nil
                                    }
                                }
                            }
                            .navigationDestination(for: ItemContent.self) { item in
                                ItemContentView(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
                            }
                            .navigationDestination(for: Person.self) { person in
                                PersonDetailsView(title: person.name, id: person.id)
                            }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var searchOverlay: some View {
        switch viewModel.phase {
        case .empty:
            if !viewModel.trimmedQuery.isEmpty {
                ZStack {
                    Rectangle().fill(.ultraThinMaterial)
                    VStack {
                        ProgressView("Searching")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
            }
        case .success(let values) where values.isEmpty:
            ZStack {
                Rectangle().fill(.ultraThinMaterial)
                Label("No Results", systemImage: "minus.magnifyingglass")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
        case .success(_):
            List {
                ForEach(viewModel.searchItems) { item in
                    SearchItem(item: item)
                        .onTapGesture {
                            selectedSearchItem = item
                        }
                }
            }
            .listStyle(.inset)
        case .failure(let error):
            ZStack {
                Rectangle().fill(.ultraThinMaterial)
                RetryView(message: error.localizedDescription, retryAction: {
                    Task {
                        await viewModel.search(query: viewModel.query)
                    }
                })
            }
        }
    }
}

struct SideBarView_Previews: PreviewProvider {
    static var previews: some View {
        SideBarView()
    }
}

