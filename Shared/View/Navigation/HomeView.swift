//
//  HomeView.swift
//  Story
//
//  Created by Alexandre Madeira on 10/02/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct HomeView: View {
    static let tag: Screens? = .home
    @AppStorage("showOnboarding") private var displayOnboard = true
    @AppStorage("isNotificationAllowed") private var notificationAllowed = true
    @StateObject private var viewModel: HomeViewModel
    @StateObject private var settings: SettingsStore
    @State private var showSettings = false
    @State private var showNotifications = false
    @State private var showConfirmation = false
    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel())
        _settings = StateObject(wrappedValue: SettingsStore())
    }
    var body: some View {
        ZStack {
            if !viewModel.isLoaded {
                ProgressView("Loading")
                    .unredacted()
            }
            VStack {
                ScrollView {
                    UpcomingWatchlist()
                    PinItemsList()
                    ItemContentListView(items: viewModel.trending,
                                        title: "Trending",
                                        subtitle: "Today",
                                        image: "crown",
                                        addedItemConfirmation: $showConfirmation)
                    ForEach(viewModel.sections) { section in
                        ItemContentListView(items: section.results,
                                            title: section.title,
                                            subtitle: section.subtitle,
                                            image: section.image,
                                            addedItemConfirmation: $showConfirmation)
                    }
                    AttributionView()
                }
                .refreshable { viewModel.reload() }
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
            .redacted(reason: !viewModel.isLoaded ? .placeholder : [] )
            .navigationTitle("Home")
            .toolbar {
#if os(macOS)
                ToolbarItem(placement: .primaryAction) {
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
                    .environmentObject(settings)
#endif
            }
            .sheet(isPresented: $showNotifications) {
                NotificationListView(showNotification: $showNotifications)
#if os(macOS)
                    .frame(width: 800, height: 500)
#endif
            }
            .task {
                await viewModel.load()
            }
            ConfirmationDialogView(showConfirmation: $showConfirmation)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
