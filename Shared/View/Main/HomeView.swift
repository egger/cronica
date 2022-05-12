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
    @State private var showAccount: Bool = false
    @State private var isLoading: Bool = true
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
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                ComingSoonListView()
                UpcomingSeasonListView()
                TrendingListView(items: viewModel.trendingSection)
                if let sections = viewModel.sections {
                    ForEach(sections) {
                        ContentListView(type: $0.type,
                                        title: $0.title,
                                        subtitle: $0.subtitle,
                                        image: $0.image,
                                        items: $0.results)
                    }
                }
                AttributionView()
            }
            .redacted(reason: isLoading ? .placeholder : [] )
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        showAccount.toggle()
                    }, label: {
                        Label("Account", systemImage: "gear.circle")
                    })
                }
            }
            .sheet(isPresented: $displayOnboard) {
                WelcomeView()
            }
            .sheet(isPresented: $showAccount) {
                NavigationView {
                    AccountView()
                        .navigationTitle("Settings")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem {
                                Button("Done") {
                                    showAccount.toggle()
                                }
                            }
                        }
                        .environmentObject(store)
                }
            }
            .task { load() }
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
