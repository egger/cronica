//
//  SideBarView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 28/04/22.
//
import SwiftUI

#if os(macOS)
struct SideBarView: View {
    @SceneStorage("selectedView") private var selectedView: Screens = .home
    @StateObject private var viewModel = SearchViewModel()
    @State private var selectedSearchItem: ItemContent?
	@State private var showNotifications = false
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
#if os(macOS)
			.overlay(search)
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
        .sheet(isPresented: $showNotifications) {
            NotificationListView(showNotification: $showNotifications)
        }
        .sheet(item: $selectedSearchItem) { item in
            if item.media == .person {
                NavigationStack {
                    PersonDetailsView(title: item.itemTitle, id: item.id)
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
					LazyVGrid(columns: columns, spacing: 20) {
						ForEach(viewModel.items) { item in
							if item.media == .person {
								PersonSearchImage(item: item)
							} else {
								SearchContentPosterView(item: item,
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
                    .navigationDestination(for: ItemContent.self) { item in
						ItemContentDetails(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
                    }
					.navigationDestination(for: SearchItemContent.self) { item in
						if item.media == .person {
							PersonDetailsView(title: item.itemTitle, id: item.id)
						} else {
							ItemContentDetails(title: item.itemTitle, id: item.id, type: item.media)
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
