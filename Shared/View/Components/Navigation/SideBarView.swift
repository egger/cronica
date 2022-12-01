//
//  SideBarView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 28/04/22.
//
import SwiftUI

struct SideBarView: View {
    @AppStorage("selectedView") private var selectedView: Screens?
    @StateObject private var settings: SettingsStore
    @StateObject private var viewModel: SearchViewModel
    @State private var showSettings = false
    @State private var showNotifications = false
    @State private var selectedSearchItem: ItemContent? = nil
    @State private var scope: SearchItemsScope = .noScope
    private let persistence = PersistenceController.shared
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
                .dropDestination(for: ItemContent.self) { items, _  in
                    for item in items {
                        PersistenceController.shared.save(item)
                    }
                    return true
                }
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
            .task(id: viewModel.query) {
                await viewModel.search(viewModel.query)
            }
            .overlay(searchOverlay)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {
                            showNotifications.toggle()
                        }, label: {
                            Label("Notifications", systemImage: "bell")
                        })
                        Button(action: {
                            showSettings.toggle()
                        }, label: {
                            Label("Settings", systemImage: "gearshape")
                        })
                    }
                }
            }
        } detail: {
            NavigationStack {
                switch selectedView {
                case .discover: DiscoverView(columns: DrawingConstants.columns)
                case .watchlist:
                    WatchlistView()
                        .environment(\.managedObjectContext, persistence.container.viewContext)
                default: HomeView()
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(showSettings: $showSettings)
                .environmentObject(settings)
        }
        .sheet(isPresented: $showNotifications) {
            NotificationListView(showNotification: $showNotifications)
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
                            ItemContentDetails(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
                        }
                        .navigationDestination(for: Person.self) { person in
                            PersonDetailsView(title: person.name, id: person.id)
                        }
                }
            } else {
                NavigationStack {
                    ItemContentDetails(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Done") {
                                    selectedSearchItem = nil
                                }
                            }
                        }
                        .navigationDestination(for: ItemContent.self) { item in
                            ItemContentDetails(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
                        }
                        .navigationDestination(for: Person.self) { person in
                            PersonDetailsView(title: person.name, id: person.id)
                        }
                }
            }
        }
    }
    
    @ViewBuilder
    private var searchOverlay: some View {
        switch viewModel.stage {
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
            List {
                switch scope {
                case .noScope:
                    ForEach(viewModel.items) { item in
                        SearchItemView(item: item, showConfirmation: $showConfirmation, isSidebar: true)
                            .onTapGesture {
                                selectedSearchItem = item
                            }
                    }
                    if viewModel.startPagination && !viewModel.endPagination {
                        HStack {
                            Spacer()
                            ProgressView()
                                .padding()
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        viewModel.loadMoreItems()
                                    }
                                }
                            Spacer()
                        }
                    }
                case .movies:
                    ForEach(viewModel.items.filter { $0.itemContentMedia == .movie }) { item in
                        SearchItemView(item: item, showConfirmation: $showConfirmation, isSidebar: true)
                            .onTapGesture {
                                selectedSearchItem = item
                            }
                    }
                case .shows:
                    ForEach(viewModel.items.filter { $0.itemContentMedia == .tvShow && $0.media != .person }) { item in
                        SearchItemView(item: item, showConfirmation: $showConfirmation, isSidebar: true)
                            .onTapGesture {
                                selectedSearchItem = item
                            }
                    }
                case .people:
                    ForEach(viewModel.items.filter { $0.media == .person }) { item in
                        SearchItemView(item: item, showConfirmation: $showConfirmation, isSidebar: true)
                            .onTapGesture {
                                selectedSearchItem = item
                            }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
    }
}

struct SideBarView_Previews: PreviewProvider {
    static var previews: some View {
        SideBarView()
    }
}

private struct DrawingConstants {
#if os(macOS)
    static let columns = [GridItem(.adaptive(minimum: 160))]
#else
    static let columns: [GridItem] = [GridItem(.adaptive(minimum: UIDevice.isIPad ? 240 : 160 ))]
#endif
}
