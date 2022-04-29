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
                ComingSoonListView()
                if let trending = viewModel.trendingSection {
                    TrendingView(items: trending)
                }
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
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        showAccount.toggle()
                    }, label: {
                        Label("Account", systemImage: "info.circle")
                    })
                }
            }
            .sheet(isPresented: $displayOnboard) {
                WelcomeView()
            }
            .sheet(isPresented: $showAccount) {
                NavigationView {
                    AccountView()
                        .navigationTitle("About")
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

private struct TrendingView: View {
    let items: [Content]
    var body: some View {
        VStack {
            TitleView(title: "Trending", subtitle: "This week", image: "crown")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(items) { item in
                        NavigationLink(destination: ContentDetailsView(title: item.itemTitle, id: item.id, type: item.itemContentMedia)) {
                            PosterView(title: item.itemTitle, url: item.posterImageMedium)
                                .padding([.leading, .trailing], 4)
                        }
                        .buttonStyle(.plain)
                        .padding(.leading, item.id == items.first!.id ? 16 : 0)
                        .padding(.trailing, item.id == items.last!.id ? 16 : 0)
                        .padding([.top, .bottom])
                    }
                }
            }
        }
    }
}
