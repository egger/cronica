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
    @State private var scope: SearchItemsScope = .noScope
    let persistence = PersistenceController.shared
    @State private var showConfirmation = false
    @State private var isInWatchlist = false
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
                .dropDestination(for: ItemContent.self) { items, location  in
                    let context = PersistenceController.shared
                    for item in items {
                        context.save(item)
                    }
                    return true
                } isTargeted: { inDropArea in
                    print(inDropArea)
                }
//#if targetEnvironment(simulator)
//                NavigationLink(value: Screens.developer) {
//                    Label("Developer", systemImage: "hammer")
//                }
//                .tag(DeveloperView.tag)
//#endif
            }
            .listStyle(.sidebar)
            .navigationTitle("Cronica")
            .searchable(text: $viewModel.query,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Movies, Shows, People")
            .disableAutocorrection(true)
            .searchScopes($scope) {
                ForEach(SearchItemsScope.allCases) { scope in
                    Text(scope.localizableTitle).tag(scope)
                }
            }
            .onAppear {
                viewModel.observe()
            }
            .overlay(searchOverlay)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
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
                    case .watchlist:
                        WatchlistView()
                            .environment(\.managedObjectContext, persistence.container.viewContext)
                    default: HomeView()
                    }
                }
                .navigationDestination(for: Screens.self) { screens in
                    switch screens {
                    case .home: HomeView()
                    case .discover: DiscoverView()
                    case .watchlist:
                        WatchlistView()
                            .environment(\.managedObjectContext, persistence.container.viewContext)
                    case .search: SearchView()
                    case .developer: DeveloperView()
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
                switch scope {
                case .noScope:
                    ForEach(viewModel.searchItems) { item in
                        SearchItemView(item: item, showConfirmation: $showConfirmation, isSidebar: true)
                            .onTapGesture {
                                selectedSearchItem = item
                            }
                    }
                case .movies:
                    ForEach(viewModel.searchItems.filter { $0.itemContentMedia == .movie }) { item in
                        SearchItemView(item: item, showConfirmation: $showConfirmation, isSidebar: true)
                            .onTapGesture {
                                selectedSearchItem = item
                            }
                    }
                case .shows:
                    ForEach(viewModel.searchItems.filter { $0.itemContentMedia == .tvShow && $0.media != .person }) { item in
                        SearchItemView(item: item, showConfirmation: $showConfirmation, isSidebar: true)
                            .onTapGesture {
                                selectedSearchItem = item
                            }
                    }
                case .people:
                    ForEach(viewModel.searchItems.filter { $0.media == .person }) { item in
                        SearchItemView(item: item, showConfirmation: $showConfirmation, isSidebar: true)
                            .onTapGesture {
                                selectedSearchItem = item
                            }
                    }
                }
            }
            .listStyle(.inset)
        case .failure(_):
            EmptyView()
        }
    }
}

struct SideBarView_Previews: PreviewProvider {
    static var previews: some View {
        SideBarView()
    }
}
