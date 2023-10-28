//
//  HomeView.swift
//  Cronica
//
//  Created by Alexandre Madeira on 10/02/22.
//

import SwiftUI
import StoreKit

struct HomeView: View {
    static let tag: Screens? = .home
#if os(tvOS)
    @AppStorage("showOnboarding") private var displayOnboard = false
#else
    @AppStorage("showOnboarding") private var displayOnboard = true
#endif
    @StateObject private var viewModel = HomeViewModel()
    @State private var showNotifications = false
    @State private var showPopup = false
    @State private var reloadHome = false
    @State private var showWhatsNew = false
    @State private var hasNotifications = false
    @State private var popupType: ActionPopupItems?
#if os(iOS)
    @AppStorage("launchCount") var launchCount: Int = 0
    @AppStorage("askedForReview") var askedForReview = false
    @State private var showReviewBanner = false
    @State private var showSettings = false
    @Environment(\.requestReview) var requestReview
#endif
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
#if os(iOS)
                if showReviewBanner { reviewAppBanner.unredacted() }
#endif
                HorizontalUpNextListView(shouldReload: $reloadHome)
                UpcomingWatchlist(shouldReload: $reloadHome)
                PinItemsList(showPopup: $showPopup, popupType: $popupType, shouldReload: $reloadHome)
                HorizontalPinnedList(showPopup: $showPopup, popupType: $popupType, shouldReload: $reloadHome)
                HorizontalItemContentListView(items: viewModel.trending,
                                              title: "Trending",
                                              subtitle: "Today",
                                              showPopup: $showPopup,
                                              popupType: $popupType)
                ForEach(viewModel.sections) { section in
                    HorizontalItemContentListView(items: section.results,
                                                  title: section.title,
                                                  subtitle: section.subtitle,
                                                  showPopup: $showPopup,
                                                  popupType: $popupType,
                                                  endpoint: section.endpoint)
                }
                HorizontalItemContentListView(items: viewModel.recommendations,
                                              title: "recommendationsTitle",
                                              subtitle: "recommendationsSubtitle",
                                              showPopup: $showPopup,
                                              popupType: $popupType)
                .redacted(reason: viewModel.isLoadingRecommendations ? .placeholder : [] )
                HorizontalItemContentListView(items: viewModel.yearMovies,
                                              title: "Coming Next Year",
                                              subtitle: "2024's Movies",
                                              showPopup: $showPopup,
                                              popupType: $popupType,
                                              displayAsCard: false,
                                              endpoint: nil)
                AttributionView()
            }
#if os(iOS)
            .refreshable {
                reloadHome = true
                viewModel.reload()
            }
            .onAppear {
                checkAskForReview()
            }
#endif
        }
        .overlay { if !viewModel.isLoaded { ProgressView("Loading").unredacted() } }
        .actionPopup(isShowing: $showPopup, for: popupType)
#if os(tvOS)
        .ignoresSafeArea(.all, edges: .horizontal)
#endif
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
#if os(tvOS)
            .ignoresSafeArea(.all, edges: .horizontal)
#endif
        }
        .navigationDestination(for: Person.self) { person in
            PersonDetailsView(name: person.name, id: person.id)
#if os(tvOS)
                .ignoresSafeArea(.all, edges: .horizontal)
#endif
        }
        .navigationDestination(for: WatchlistItem.self) { item in
            ItemContentDetails(title: item.itemTitle,
                               id: item.itemId,
                               type: item.itemMedia)
#if os(tvOS)
            .ignoresSafeArea(.all, edges: .horizontal)
#endif
        }
        .navigationDestination(for: Endpoints.self) { endpoint in
            EndpointDetails(title: endpoint.title,
                            endpoint: endpoint)
        }
#if os(iOS) || os(macOS)
        .navigationDestination(for: [WatchlistItem].self) { item in
            WatchlistSectionDetails(items: item)
        }
        .navigationDestination(for: [String:[WatchlistItem]].self) { item in
            let keys = item.map { (key, _) in key }
            let value = item.map { (_, value) in value }
            WatchlistSectionDetails(title: keys[0], items: value[0])
        }
#endif
        .navigationDestination(for: [String:[ItemContent]].self) { item in
            let keys = item.map { (key, _) in key }
            let value = item.map { (_, value) in value }
            ItemContentSectionDetails(title: keys[0], items: value[0])
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
#if os(iOS) || os(macOS)
        .navigationTitle("Home")
#endif
        #if os(iOS)
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        #endif
        .toolbar {
#if os(macOS)
            ToolbarItem(placement: .navigation) {
                HStack {
                    Button {
                        showNotifications.toggle()
                    } label: {
                        Label("Notifications", systemImage: hasNotifications ? "bell.badge.fill" : "bell")
                            .labelStyle(.iconOnly)
                    }
                    Button {
                        reloadHome = true
                        viewModel.reload()
                    } label: {
                        Label("Reload", systemImage: "arrow.clockwise")
                            .labelStyle(.iconOnly)
                    }
                    .keyboardShortcut("r", modifiers: .command)
                }
            }
#elseif os(iOS)
            if UIDevice.isIPad {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showSettings.toggle()
                    } label: {
                        Image(systemName: "gearshape")
                            .fontDesign(.rounded)
                            .fontWeight(.semibold)
                            .imageScale(.medium)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .buttonStyle(.borderedProminent)
                    .contentShape(Circle())
                    .clipShape(Circle())
                    .tint(SettingsStore.shared.appTheme.color.opacity(0.7))
                    .shadow(radius: 2.5)
                    .accessibilityLabel("Settings")
                    .applyHoverEffect()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showNotifications.toggle()
                } label: {
                    Image(systemName: hasNotifications ? "bell.badge.fill" : "bell")
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                        .imageScale(.medium)
                        .foregroundColor(.white.opacity(0.9))
                }
                .buttonStyle(.borderedProminent)
                .contentShape(Circle())
                .clipShape(Circle())
                .tint(SettingsStore.shared.appTheme.color.opacity(0.7))
                .shadow(radius: 2.5)
                .accessibilityLabel("Notifications")
                .applyHoverEffect()
            }
#endif
        }
        .sheet(isPresented: $displayOnboard) {
            WelcomeView()
#if os(macOS)
                .frame(width: 500, height: 700, alignment: .center)
#endif
        }
        .sheet(isPresented: $showNotifications) {
#if os(iOS) || os(macOS)
            NotificationListView(showNotification: $showNotifications)
                .appTheme()
				.onDisappear {
					Task {
						let notifications = await NotificationManager.shared.hasDeliveredItems()
						hasNotifications = notifications
					}
				}
#if os(macOS)
                .frame(width: 800, height: 500)
#endif
#endif
        }
        .task {
            await viewModel.load()
        }
    }
    
    private func checkVersion() {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let lastSeenVersion = UserDefaults.standard.string(forKey: UserDefaults.lastSeenAppVersionKey)
        if SettingsStore.shared.displayOnboard {
            return
        } else {
            if currentVersion != lastSeenVersion {
                // showWhatsNew.toggle()
                UserDefaults.standard.set(currentVersion, forKey: UserDefaults.lastSeenAppVersionKey)
            }
        }
    }
    
#if os(iOS)
    private func checkAskForReview() {
        if launchCount < 20 {
            launchCount += 1
        } else {
            if !askedForReview {
                withAnimation { showReviewBanner = true }
            }
            askedForReview = true
        }
    }
    
    private var reviewAppBanner: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("callToReviewTitle")
                    .font(.title3)
                    .fontDesign(.rounded)
                    .padding(.leading)
                    .fontWeight(.semibold)
                Text("callToReviewSubtitle")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .fontDesign(.rounded)
                    .padding(.leading)
                    .padding(.bottom, 4)
                    .fontWeight(.regular)
                Button("reviewInTheAppStore") {
                    requestReview()
                }
                .padding(.leading)
                .padding(.bottom, 4)
            }
            Spacer()
            VStack {
                Button {
                    withAnimation { showReviewBanner = false }
                } label: {
                    Label("dismissReviewCall", systemImage: "xmark")
                        .labelStyle(.iconOnly)
                }
                .clipShape(Circle())
                .buttonStyle(.bordered)
                Spacer()
            }
            .padding(.trailing)
        }.padding(.vertical)
    }
#endif
}

#Preview {
    HomeView()
}
