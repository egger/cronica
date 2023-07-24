//
//  SideBarView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 28/04/22.
//
import SwiftUI

#if os(iOS) || os(macOS)
struct SideBarView: View {
#if os(iOS)
    @SceneStorage("selectedView") private var selectedView: Screens?
#else
    @SceneStorage("selectedView") private var selectedView: Screens = .home
#endif
    @StateObject private var viewModel = SearchViewModel()
    @State private var showSettings = false
    @State private var showNotifications = false
    @State private var selectedSearchItem: ItemContent?
    @State private var scope: SearchItemsScope = .noScope
    private let persistence = PersistenceController.shared
    @State private var showPopup = false
    @State private var isInWatchlist = false
    @State private var isSearching = false
    @State private var popupType: ActionPopupItems?
    private let columns: [GridItem] = [GridItem(.adaptive(minimum: 160))]
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedView) {
                NavigationLink(value: Screens.home) {
                    Label("Home", systemImage: "house")
                }
                .tag(HomeView.tag)
                
                NavigationLink(value: Screens.explore) {
                    Label("Explore", systemImage: "popcorn")
                }
                .tag(ExploreView.tag)
                
                NavigationLink(value: Screens.watchlist) {
                    Label("Watchlist", systemImage: "square.stack")
                }
                .tag(WatchlistView.tag)
            }
            .listStyle(.sidebar)
            .navigationTitle("Cronica")
#if os(iOS)
            .searchable(text: $viewModel.query,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Movies, Shows, People")
            .searchScopes($scope) {
                ForEach(SearchItemsScope.allCases) { scope in
                    Text(scope.localizableTitle).tag(scope)
                }
            }
            .overlay(search)
#elseif os(macOS)
            .searchable(text: $viewModel.query, placement: .toolbar, prompt: "Movies, Shows, People")
#endif
            .disableAutocorrection(true)
            
            .task(id: viewModel.query) {
#if os(macOS)
                if !viewModel.query.isEmpty {
                    isSearching = true
                } else {
                    isSearching = false
                }
#endif
                await viewModel.search(viewModel.query)
            }
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button {
                            showNotifications.toggle()
                        } label: {
                            Label("Notifications", systemImage: "bell")
                        }
                        Button {
                            showSettings.toggle()
                        } label: {
                            Label("Settings", systemImage: "gearshape")
                        }
                    }
                }
#endif
            }
        } detail: {
#if os(macOS)
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
                        NavigationStack { ExploreView() }
                    case .watchlist:
                        NavigationStack {
                            WatchlistView()
                                .environment(\.managedObjectContext, persistence.container.viewContext)
                        }
                    }
                }
            }
#else
            NavigationStack {
                switch selectedView {
                case .explore: ExploreView()
                case .watchlist:
                    WatchlistView()
                        .environment(\.managedObjectContext, persistence.container.viewContext)
                default: HomeView()
                }
            }
#endif
        }
        .navigationSplitViewStyle(.balanced)
#if os(iOS)
        .appTheme()
#endif
        .sheet(isPresented: $showNotifications) {
#if os(iOS) || os(macOS)
            NotificationListView(showNotification: $showNotifications)
#if os(iOS)
                .appTheme()
                .appTint()
#endif
#endif
        }
        .sheet(item: $selectedSearchItem) { item in
            if item.media == .person {
                NavigationStack {
                    PersonDetailsView(title: item.itemTitle, id: item.id)
                        .toolbar {
#if os(iOS)
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Done") {
                                    selectedSearchItem = nil
                                }
                            }
#endif
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
#if os(iOS)
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Done") {
                                    selectedSearchItem = nil
                                }
                            }
#endif
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
    
#if os(iOS)
    @ViewBuilder
    private var search: some View {
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
                        SearchItemView(item: item,
                                       showPopup: $showPopup,
                                       popupType: $popupType,
                                       isSidebar: true)
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
                        SearchItemView(item: item,
                                       showPopup: $showPopup,
                                       popupType: $popupType,
                                       isSidebar: true)
                            .onTapGesture {
                                selectedSearchItem = item
                            }
                    }
                case .shows:
                    ForEach(viewModel.items.filter { $0.itemContentMedia == .tvShow && $0.media != .person }) { item in
                        SearchItemView(item: item,
                                       showPopup: $showPopup,
                                       popupType: $popupType,
                                       isSidebar: true)
                            .onTapGesture {
                                selectedSearchItem = item
                            }
                    }
                case .people:
                    ForEach(viewModel.items.filter { $0.media == .person }) { item in
                        SearchItemView(item: item,
                                       showPopup: $showPopup,
                                       popupType: $popupType,
                                       isSidebar: true)
                            .onTapGesture {
                                selectedSearchItem = item
                            }
                    }
                }
            }
#if os(iOS)
            .listStyle(.insetGrouped)
#endif
        }
    }
#endif
    
#if os(macOS)
    @ViewBuilder
    private var search: some View {
        switch viewModel.stage {
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
                                ForEach(viewModel.items) { item in
                                    if item.media == .person {
                                        PersonSearchImage(item: item)
                                    } else {
                                        ItemContentPosterView(item: item,
                                                              showPopup: $showPopup,
                                                              popupType: $popupType)
                                    }
                                }
                                .buttonStyle(.plain)
                                if viewModel.startPagination && !viewModel.endPagination {
                                    CenterHorizontalView {
                                        ProgressView()
                                            .padding()
                                            .onAppear {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                    withAnimation {
                                                        viewModel.loadMoreItems()
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
                            ItemContentDetails(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
                        }
                    }
                }
                .navigationTitle("Search")
            }
        }
    }
#endif
}

struct SideBarView_Previews: PreviewProvider {
    static var previews: some View {
        SideBarView()
    }
}
#endif
