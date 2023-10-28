//
//  SideBarView.swift
//  Cronica (iOS)
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
            .searchable(text: $viewModel.query, placement: .toolbar, prompt: "Movies, Shows, People")
            .disableAutocorrection(true)
            
            .task(id: viewModel.query) {
                if !viewModel.query.isEmpty {
                    isSearching = true
                } else {
                    isSearching = false
                }
                await viewModel.search(viewModel.query)
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
    }
    
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
                    ContentUnavailableView("No Results", systemImage: "magnifyingglass")
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
                    ContentUnavailableView("Search failed, try again later.", systemImage: "magnifyingglass")
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
				VStack {
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
                                PersonDetailsView(name: item.itemTitle, id: item.id)
							} else {
								ItemContentDetails(title: item.itemTitle, id: item.id, type: item.media)
							}
						}
					}
				}
				.padding()
                .navigationTitle("Search")
            }
        }
    }
}

#Preview {
    SideBarView()
}
#endif
