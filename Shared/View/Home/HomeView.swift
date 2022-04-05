//
//  HomeView.swift
//  Story
//
//  Created by Alexandre Madeira on 10/02/22.
//

import SwiftUI

struct HomeView: View {
    static let tag: String? = "Home"
#if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
#endif
    @AppStorage("showOnboarding") var displayOnboard = true
    @StateObject private var viewModel: HomeViewModel
    @State private var showAccount: Bool = false
    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel())
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
    
    @ViewBuilder
    var detailsView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                WatchlistSectionView()
                if !viewModel.trendingSection.isEmpty {
                    TitleView(title: "Trending", subtitle: "This week", image: "crown")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.trendingSection) { item in
                                NavigationLink(destination: DetailsView(title: item.itemTitle, id: item.id, type: item.itemContentMedia)) {
                                    PosterView(title: item.itemTitle, url: item.posterImageMedium)
                                        .padding([.leading, .trailing], 4)
                                }
                                .padding(.leading, item.id == viewModel.trendingSection.first!.id ? 16 : 0)
                                .padding(.trailing, item.id == viewModel.trendingSection.last!.id ? 16 : 0)
                                .padding([.top, .bottom])
                            }
                        }
                    }
                }
                ForEach(viewModel.moviesSections) {
                    ContentListView(style: $0.style,
                                    type: MediaType.movie,
                                    title: $0.title,
                                    subtitle: $0.subtitle,
                                    image: $0.image,
                                    items: $0.results)
                }
                ForEach(viewModel.tvSections) {
                    ContentListView(style: $0.style,
                                    type: MediaType.tvShow,
                                    title: $0.title,
                                    subtitle: $0.subtitle,
                                    image: $0.image,
                                    items: $0.results)
                }
                AttributionView()
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem {
                    Button {
                        showAccount.toggle()
                    } label: {
                        Label("Account", systemImage: "person.crop.circle")
                    }
                }
            }
            .fullScreenCover(isPresented: $displayOnboard, content: {
                WelcomeView()
            })
            .sheet(isPresented: $showAccount) {
                NavigationView {
                    AccountView()
                        .environmentObject(SettingsStore())
                        .navigationTitle("Account")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem {
                                Button("Done") {
                                    showAccount.toggle()
                                }
                            }
                        }
                }
            }
            .task { load() }
        }
    }
    
    @Sendable
    private func load() {
        Task {
            await viewModel.load()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
