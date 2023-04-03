//
//  HomeView.swift
//  Story
//
//  Created by Alexandre Madeira on 10/02/22.
//

import SwiftUI
#if os(iOS) || os(macOS)
struct HomeView: View {
    static let tag: Screens? = .home
    @AppStorage("showOnboarding") private var displayOnboard = true
    @StateObject private var viewModel = HomeViewModel()
    @State private var showSettings = false
    @State private var showNotifications = false
    @State private var showConfirmation = false
    @State private var reloadUpNext = false
    var body: some View {
        ZStack {
            if !viewModel.isLoaded { ProgressView("Loading").unredacted() }
            VStack(alignment: .leading) {
                ScrollView {
                    UpNextView(shouldReload: $reloadUpNext)
                    UpcomingWatchlist()
                    PinItemsList()
                    ItemContentListView(items: viewModel.trending,
                                        title: "Trending",
                                        subtitle: "Today",
                                        addedItemConfirmation: $showConfirmation)
                    ForEach(viewModel.sections) { section in
                        ItemContentListView(items: section.results,
                                            title: section.title,
                                            subtitle: section.subtitle,
                                            addedItemConfirmation: $showConfirmation,
                                            endpoint: section.endpoint)
                    }
                    ItemContentListView(items: viewModel.recommendations,
                                        title: "recommendationsTitle",
                                        subtitle: "recommendationsSubtitle",
                                        addedItemConfirmation: $showConfirmation,
                                        displayAsCard: false)
                    AttributionView()
                }
                .refreshable {
                    reloadUpNext = true
                    viewModel.reload()
                }
            }
            .navigationDestination(for: ItemContent.self) { item in
#if os(macOS)
                ItemContentDetailsView(id: item.id, title: item.itemTitle, type: item.itemContentMedia)
#else
                ItemContentDetails(title: item.itemTitle,
                                   id: item.id,
                                   type: item.itemContentMedia)
#endif
            }
            .navigationDestination(for: Person.self) { person in
                PersonDetailsView(title: person.name, id: person.id)
            }
            .navigationDestination(for: WatchlistItem.self) { item in
#if os(macOS)
                ItemContentDetailsView(id: item.itemId, title: item.itemTitle, type: item.itemMedia)
#else
                ItemContentDetails(title: item.itemTitle,
                                   id: item.itemId,
                                   type: item.itemMedia)
#endif
            }
            .navigationDestination(for: [WatchlistItem].self) { item in
                TitleWatchlistDetails(items: item)
            }
            .navigationDestination(for: Endpoints.self) { endpoint in
                EndpointDetails(title: endpoint.title,
                                endpoint: endpoint)
            }
            .navigationDestination(for: [String:[WatchlistItem]].self) { item in
                let keys = item.map { (key, _) in key }
                let value = item.map { (_, value) in value }
                TitleWatchlistDetails(title: keys[0], items: value[0])
            }
            .navigationDestination(for: [String:[ItemContent]].self) { item in
                let keys = item.map { (key, _) in key }
                let value = item.map { (_, value) in value }
                ItemContentCollectionDetails(title: keys[0], items: value[0])
            }
            .navigationDestination(for: [Person].self) { items in
                DetailedPeopleList(items: items)
            }
            .navigationDestination(for: ProductionCompany.self) { item in
                CompanyDetails(company: item)
            }
            .navigationDestination(for: [ProductionCompany].self) { item in
                CompaniesListView(companies: item)
            }
            .redacted(reason: !viewModel.isLoaded ? .placeholder : [] )
            .navigationTitle("Home")
            .toolbar {
#if os(macOS)
                ToolbarItem(placement: .navigation) {
                    Button {
                        showNotifications.toggle()
                    } label: {
                        Label("Notifications", systemImage: "bell")
                    }
                }
#else
                if UIDevice.isIPhone {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            Button(action: {
                                showNotifications.toggle()
                            }, label: {
                                Label("Notifications",
                                      systemImage: "bell")
                            })
                            
                            Button(action: {
                                showSettings.toggle()
                            }, label: {
                                Label("Settings", systemImage: "gearshape")
                            })
                        }
                    }
                }
#endif
            }
            .sheet(isPresented: $displayOnboard) {
                WelcomeView()
#if os(macOS)
                    .frame(width: 500, height: 700, alignment: .center)
#endif
            }
            .sheet(isPresented: $showSettings) {
#if os(iOS)
                SettingsView(showSettings: $showSettings)
                    .interactiveDismissDisabled()
#endif
            }
            .sheet(isPresented: $showNotifications) {
                NotificationListView(showNotification: $showNotifications)
                    .appTheme()
#if os(macOS)
                    .frame(width: 800, height: 500)
#endif
            }
            .task {
                await viewModel.load()
            }
            ConfirmationDialogView(showConfirmation: $showConfirmation, message: "addedToWatchlist")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
#endif
