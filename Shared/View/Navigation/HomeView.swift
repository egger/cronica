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
    var body: some View {
        ZStack {
            if !viewModel.isLoaded { ProgressView("Loading").unredacted() }
            VStack(alignment: .leading) {
                ScrollView {
#if os(iOS) || os(macOS)
                    UpNextView(shouldReload: $reloadUpNext)
#endif
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
                                        addedItemConfirmation: $showConfirmation)
                    AttributionView()
                }
                .refreshable {
                    reloadUpNext = true
                    viewModel.reload()
                }
            }
            .onAppear {
                checkVersion()
            }
            .sheet(isPresented: $showWhatsNew) {
#if os(iOS) || os(macOS)
                ChangelogView(showChangelog: $showWhatsNew)
                    .onDisappear {
                        showWhatsNew = false
                    }
#endif
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
#if os(tvOS)
                TVPersonDetailsView(title: person.name, id: person.id)
#else
                PersonDetailsView(title: person.name, id: person.id)
#endif
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
#if os(tvOS)
#else
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
                        Label("Notifications", systemImage: "bell")
                    }
                }
#elseif os(iOS)
                if UIDevice.isIPhone {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            Button {
                                showNotifications.toggle()
                            } label: {
                                Label("Notifications",
                                      systemImage: "bell")
                            }
                            
                            Button {
                                showSettings.toggle()
                            } label: {
                                Label("Settings", systemImage: "gearshape")
                            }
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
#endif
            }
            .sheet(isPresented: $showNotifications) {
#if os(tvOS)
#else
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
                //showWhatsNew.toggle()
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
