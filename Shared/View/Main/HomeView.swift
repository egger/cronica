//
//  HomeView.swift
//  Story
//
//  Created by Alexandre Madeira on 10/02/22.
//

import SwiftUI

struct HomeView: View {
    static let tag: Screens? = .home
#if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
#endif
    @AppStorage("showOnboarding") var displayOnboard = true
    @StateObject private var viewModel: HomeViewModel
    @StateObject private var store: SettingsStore
    @State private var showSettings: Bool = false
    @State private var isLoading: Bool = true
    @State private var showConfirmation: Bool = false
    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel())
        _store = StateObject(wrappedValue: SettingsStore())
    }
    @ViewBuilder
    var body: some View {
#if os(iOS)
        if horizontalSizeClass == .compact {
            NavigationView {
                detailsView
            }
            .navigationViewStyle(.stack)
        } else {
            detailsView
        }
#else
        detailsView
#endif
    }
    
    var detailsView: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    WatchListUpcomingMoviesListView()
                    WatchListUpcomingSeasonsListView()
                    TrendingListView(items: viewModel.trendingSection,
                                     showConfirmation: $showConfirmation)
                    if let sections = viewModel.sections {
                        ForEach(sections) {
                            ContentListView(type: $0.type,
                                            title: $0.title,
                                            subtitle: $0.subtitle,
                                            image: $0.image,
                                            items: $0.results,
                                            showConfirmation: $showConfirmation)
                        }
                    }
                    AttributionView()
                }
                .redacted(reason: isLoading ? .placeholder : [] )
                .navigationTitle("Home")
                .toolbar {
                    ToolbarItem {
                        Button(action: {
                            HapticManager.shared.softHaptic()
                            showSettings.toggle()
                        }, label: {
                            Label("Settings", systemImage: "gearshape")
                        })
                    }
                }
                .sheet(isPresented: $displayOnboard) {
                    WelcomeView()
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView(showSettings: $showSettings)
                        .environmentObject(store)
                }
                .task { load() }
            }
            ConfirmationDialogView(showConfirmation: $showConfirmation)
        }
    }
    
    @Sendable
    private func load() {
        Task {
            await viewModel.load()
            withAnimation {
                isLoading = false
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
