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
                await searchViewModel.search(searchViewModel.query)
            }
            .searchable(text: $searchViewModel.query,
                        placement: .toolbar,
                        prompt: "Movies, Shows, People")
            .disableAutocorrection(true)
            .searchScopes($scope) {
                ForEach(SearchItemsScope.allCases) { scope in
                    Text(scope.localizableTitle).tag(scope)
                }
            }
            .navigationTitle("Cronica")
        } detail: {
            ZStack {
                switch selectedView {
                case .home:
                    HomeView()
                        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                case .discover:
                    DiscoverView()
                case .watchlist:
                    WatchlistView()
                        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                case .search:
                    EmptyView()
                }
            }
            .overlay(searchOverlay)
            .sheet(item: $selectedSearchItem) { item in
                if item.media == .person {
                    NavigationStack {
                        PersonDetailsView(title: item.itemTitle, id: item.id)
                            .frame(width: 900, height: 400)
                            .toolbar {
                                Button("Done") { selectedSearchItem = nil }
                            }
                            .navigationDestination(for: ItemContent.self) { item in
                                ItemContentDetailsView(id: item.id, title: item.itemTitle, type: item.itemContentMedia)
                            }
                            .navigationDestination(for: Person.self) { item in
                                PersonDetailsView(title: item.name, id: item.id)
                            }
                    }
                } else {
                    NavigationStack {
                        ItemContentDetailsView(id: item.id, title: item.itemTitle, type: item.media)
                            .frame(width: 900, height: 400)
                            .toolbar {
                                Button("Done") { selectedSearchItem = nil }
                            }
                    }
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
    
    @ViewBuilder
    private var searchOverlay: some View {
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
            ZStack {
                HStack {
                    Spacer()
                    List {
                        switch scope {
                        case .noScope:
                            ForEach(searchViewModel.items) { item in
                                SearchItemView(item: item, showConfirmation: $showConfirmation, isSidebar: true)
                                    .onTapGesture {
                                        selectedSearchItem = item
                                    }
                            }
                            if searchViewModel.startPagination && !searchViewModel.endPagination {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .padding()
                                        .onAppear {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                searchViewModel.loadMoreItems()
                                            }
                                        }
                                    Spacer()
                                }
                            }
                        case .movies:
                            ForEach(searchViewModel.items.filter { $0.itemContentMedia == .movie }) { item in
                                SearchItemView(item: item, showConfirmation: $showConfirmation, isSidebar: true)
                                    .onTapGesture {
                                        selectedSearchItem = item
                                    }
                            }
                        case .shows:
                            ForEach(searchViewModel.items.filter { $0.itemContentMedia == .tvShow && $0.media != .person }) { item in
                                SearchItemView(item: item, showConfirmation: $showConfirmation, isSidebar: true)
                                    .onTapGesture {
                                        selectedSearchItem = item
                                    }
                            }
                        case .people:
                            ForEach(searchViewModel.items.filter { $0.media == .person }) { item in
                                SearchItemView(item: item, showConfirmation: $showConfirmation, isSidebar: true)
                                    .onTapGesture {
                                        selectedSearchItem = item
                                    }
                            }
                        }
                    }
                    .frame(maxWidth: 400)
                }
            }
            .background(.ultraThinMaterial)
        }
    }
}

struct SideBarView_Previews: PreviewProvider {
    static var previews: some View {
        SideBarView()
    }
}


struct NotificationsView: View {
    @State private var hasLoaded = false
    @State private var items = [ItemContent]()
    @State private var deliveredItems = [ItemContent]()
    var body: some View {
        VStack {
            if hasLoaded {
                List {
                    if !items.isEmpty {
                        Section {
                            ForEach(items.sorted(by: { $0.itemTitle < $1.itemTitle })) { item in
                                ItemContentItemView(item: item, subtitle: item.itemSearchDescription)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true, content: {
                                        Button(role: .destructive,
                                               action: {
                                            removeNotification(id: item.itemNotificationID, for: item.id)
                                        }, label: {
                                            Label("Remove Notification", systemImage: "bell.slash.circle.fill")
                                        })
                                    })
                                    .buttonStyle(.plain)
                            }
                            .onDelete(perform: delete)
                        } header: {
                            Text("Upcoming Notifications")
                        } footer: {
                            Text("\(items.count) upcoming notifications.")
                                .padding(.bottom)
                        }
                    }
                }
            } else {
                ProgressView("Loading")
            }
        }
        .navigationTitle("Notifications")
        .navigationDestination(for: ItemContent.self) { item in
            ItemContentDetailsView(id: item.id, title: item.itemTitle, type: item.itemContentMedia)
        }
        .navigationDestination(for: Person.self) { item in
            PersonDetailsView(title: item.name, id: item.id)
        }
        .onAppear {
            Task {
                items = await NotificationManager.shared.fetchUpcomingNotifications() ?? []
                deliveredItems = await NotificationManager.shared.fetchDeliveredNotifications()
                withAnimation {
                    hasLoaded = true
                }
            }
        }
    }
    
    private func removeNotification(id: String, for content: Int) {
        NotificationManager.shared.removeNotification(identifier: id)
        items.removeAll(where: { $0.id == content })
    }
    
    private func removeDelivered(id: String, for content: Int) {
        NotificationManager.shared.removeDeliveredNotification(identifier: id)
        items.removeAll(where: { $0.id == content })
    }
    
    private func delete(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach { item in
                removeNotification(id: item.itemNotificationID, for: item.id)
            }
        }
    }
    
    private func deleteDelivered(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach { item in
                removeDelivered(id: item.itemNotificationID, for: item.id)
            }
        }
    }
}


private struct ItemContentItemView: View {
    let item: ItemContent
    let subtitle: String
    var body: some View {
        NavigationLink(value: item) {
            HStack {
                WebImage(url: item.cardImageMedium)
                    .placeholder {
                        ZStack {
                            Color.secondary
                            Image(systemName: "film")
                        }
                        .frame(width: DrawingConstants.imageWidth,
                               height: DrawingConstants.imageHeight)
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .transition(.opacity)
                    .frame(width: DrawingConstants.imageWidth,
                           height: DrawingConstants.imageHeight)
                    .frame(width: DrawingConstants.imageWidth,
                           height: DrawingConstants.imageHeight)
                    .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius))
                VStack(alignment: .leading) {
                    HStack {
                        Text(item.itemTitle)
                            .lineLimit(DrawingConstants.textLimit)
                    }
                    HStack {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
        }
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 70
    static let imageHeight: CGFloat = 50
    static let imageRadius: CGFloat = 4
    static let textLimit: Int = 1
}
