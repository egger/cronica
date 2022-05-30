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
            VStack {
                Spacer()
                HStack {
                    Label("Added to watchlist", systemImage: "checkmark.circle")
                        .tint(.green)
                        .padding()
                }
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .padding()
                .shadow(radius: 6)
                .opacity(showConfirmation ? 1 : 0)
                .scaleEffect(showConfirmation ? 1.1 : 1)
                .animation(.linear, value: showConfirmation)
            }
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
