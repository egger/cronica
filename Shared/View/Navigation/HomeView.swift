//
//  HomeView.swift
//  Story
//
//  Created by Alexandre Madeira on 10/02/22.
//

import SwiftUI

struct HomeView: View {
    static let tag: Screens? = .home
#if os(tvOS)
    @AppStorage("showOnboarding") private var displayOnboard = false
#else
    @AppStorage("showOnboarding") private var displayOnboard = true
#endif
    @StateObject private var viewModel = HomeViewModel()
    @State private var showSettings = false
    @State private var showNotifications = false
    @State private var showConfirmation = false
    @State private var reloadUpNext = false
    @State private var showWhatsNew = false
    @State private var hasNotifications = false
    var body: some View {
        ZStack {
            if !viewModel.isLoaded { ProgressView("Loading").unredacted() }
            VStack(alignment: .leading) {
                ScrollView {
#if os(iOS) || os(macOS)
                    UpNextListView(shouldReload: $reloadUpNext)
#endif
                    UpcomingWatchlist()
                    PinItemsList()
                    CustomListPinned()
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
                                        addedItemConfirmation: $showConfirmation)
                    .redacted(reason: viewModel.isLoadingRecommendations ? .placeholder : [] )
                    AttributionView()
                }
                .refreshable {
                    reloadUpNext = true
                    viewModel.reload()
                }
            }
            .onAppear {
                checkVersion()
#if os(iOS) || os(macOS)
                Task {
                    let notifications = await NotificationManager.shared.hasDeliveredItems()
                    hasNotifications = notifications
                }
#endif
            }
            .sheet(isPresented: $showWhatsNew) {
#if os(iOS) || os(macOS)
                ChangelogView(showChangelog: $showWhatsNew)
                    .onDisappear {
                        showWhatsNew = false
                    }
#if os(macOS)
                    .frame(minWidth: 400, idealWidth: 600, maxWidth: nil, minHeight: 500, idealHeight: 500, maxHeight: nil, alignment: .center)
#elseif os(iOS)
                    .appTheme()
#endif
#endif
            }
            .navigationDestination(for: ItemContent.self) { item in
                ItemContentDetails(title: item.itemTitle,
                                   id: item.id,
                                   type: item.itemContentMedia)
            }
            .navigationDestination(for: Person.self) { person in
                PersonDetailsView(title: person.name, id: person.id)
            }
            .navigationDestination(for: WatchlistItem.self) { item in
                ItemContentDetails(title: item.itemTitle,
                                   id: item.itemId,
                                   type: item.itemMedia)
            }
            .navigationDestination(for: [WatchlistItem].self) { item in
                TitleWatchlistDetails(items: item)
            }
            .navigationDestination(for: Endpoints.self) { endpoint in
#if os(iOS) || os(macOS)
                EndpointDetails(title: endpoint.title,
                                endpoint: endpoint)
#endif
            }
            .navigationDestination(for: [String:[WatchlistItem]].self) { item in
                let keys = item.map { (key, _) in key }
                let value = item.map { (_, value) in value }
                TitleWatchlistDetails(title: keys[0], items: value[0])
            }
            .navigationDestination(for: [String:[ItemContent]].self) { item in
                let keys = item.map { (key, _) in key }
                let value = item.map { (_, value) in value }
#if os(tvOS)
#else
                ItemContentCollectionDetails(title: keys[0], items: value[0])
#endif
            }
            .navigationDestination(for: [Person].self) { items in
#if os(tvOS)
#else
                DetailedPeopleList(items: items)
#endif
            }
            .navigationDestination(for: ProductionCompany.self) { item in
#if os(tvOS)
#else
                CompanyDetails(company: item)
#endif
            }
            .navigationDestination(for: [ProductionCompany].self) { item in
#if os(tvOS)
#else
                CompaniesListView(companies: item)
#endif
            }
            .redacted(reason: !viewModel.isLoaded ? .placeholder : [] )
#if os(iOS) || os(macOS)
            .navigationTitle("Home")
#endif
            .toolbar {
#if os(macOS)
                ToolbarItem(placement: .navigation) {
                    Button {
                        showNotifications.toggle()
                    } label: {
                        Image(systemName: hasNotifications ? "bell.badge.fill" : "bell")
                            .imageScale(.medium)
                    }
                }
#elseif os(iOS)
                if UIDevice.isIPhone {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showNotifications.toggle()
                        } label: {
                            Image(systemName: hasNotifications ? "bell.badge.fill" : "bell")
                                .imageScale(.medium)
                        }
                        .buttonStyle(.bordered)
                        .clipShape(Circle())
                        .tint(.secondary)
                        .shadow(radius: 2)
                        .accessibilityLabel("Notifications")
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
#endif
            }
            .sheet(isPresented: $showNotifications) {
#if os(iOS) || os(macOS)
                NotificationListView(showNotification: $showNotifications)
                    .appTheme()
#if os(macOS)
                    .frame(width: 800, height: 500)
#endif
#endif
            }
            .task {
                await viewModel.load()
            }
            ConfirmationDialogView(showConfirmation: $showConfirmation, message: "addedToWatchlist")
        }
    }
    
    private func checkVersion() {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let lastSeenVersion = UserDefaults.standard.string(forKey: UserDefaults.lastSeenAppVersionKey)
        if SettingsStore.shared.displayOnboard {
            return
        } else {
            if currentVersion != lastSeenVersion {
                showWhatsNew.toggle()
                UserDefaults.standard.set(currentVersion, forKey: UserDefaults.lastSeenAppVersionKey)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
