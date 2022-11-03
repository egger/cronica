//
//  HomeView.swift
//  CronicaMac
//
//  Created by Alexandre Madeira on 02/11/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showConfirmation = false
    @State private var showNotifications = false
    @AppStorage("showOnboarding") private var displayOnboard = true
    @Environment(\.managedObjectContext) var viewContext
    var body: some View {
        NavigationStack {
            ZStack {
                if !viewModel.isLoaded {
                    ProgressView("Loading")
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
                }
                .redacted(reason: viewModel.isLoaded ? [] : .placeholder)
                .navigationDestination(for: ItemContent.self) { item in
                    ItemContentDetailsView(id: item.id, title: item.itemTitle, type: item.itemContentMedia)
                }
                .navigationDestination(for: WatchlistItem.self) { item in
                    ItemContentDetailsView(id: item.itemId, title: item.itemTitle, type: item.itemMedia)
                }
                .navigationTitle("Home")
                .task {
                    await viewModel.load()
                }
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button {
                            showNotifications.toggle()
                        } label: {
                            Label("Notifications", systemImage: "bell")
                        }
                    }
                }
                .sheet(isPresented: $showNotifications) {
                    NotificationListView(showNotification: $showNotifications)
                        .frame(width: 800, height: 500)
                }
                .sheet(isPresented: $displayOnboard) {
                    WelcomeView()
                        .frame(width: 500, height: 700, alignment: .center)
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

