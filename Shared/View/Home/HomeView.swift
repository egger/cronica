//
//  HomeView.swift
//  Story
//
//  Created by Alexandre Madeira on 10/02/22.
//

import SwiftUI

struct HomeView: View {
    static let tag: String? = "Home"
    @StateObject private var viewModel: HomeViewModel
    @State private var showAccount: Bool = false
    @State private var showWelcomeScreen: Bool = true
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.id, ascending: true)],
        animation: .default)
    private var watchlistItems: FetchedResults<WatchlistItem>
    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel())
    }
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    if !watchlistItems.isEmpty {
                        VStack {
                            HStack {
                                Text("Coming Soon")
                                    .font(.headline)
                                    .padding([.top, .horizontal])
                                Spacer()
                            }
                            HStack {
                                Text("From Watchlist")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                Spacer()
                            }
                        }
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(watchlistItems.filter { $0.status == "Post Production"}) { item in
                                    NavigationLink(destination: DetailsView(title: item.itemTitle, id: item.itemId, type: item.itemMedia)) {
                                        PosterView(title: item.itemTitle, url: item.poster)
                                            .padding([.leading, .trailing], 4)
                                    }
                                    .padding(.leading, item.id == self.watchlistItems.first!.id ? 16 : 0)
                                    .padding(.trailing, item.id == self.watchlistItems.last!.id ? 16 : 0)
                                    .padding([.top, .bottom])
                                }
                            }
                        }
                    }
                    if !viewModel.trendingSection.isEmpty {
                        VStack {
                            HStack {
                                Text(NSLocalizedString("Trending", comment: ""))
                                    .font(.headline)
                                    .padding([.horizontal, .top])
                                Spacer()
                            }
                            HStack {
                                Text(NSLocalizedString("This week", comment: ""))
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                                    .padding(.horizontal)
                                Spacer()
                            }
                        }
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
                        ContentListView(style: $0.style, type: MediaType.movie, title: $0.title, items: $0.results)
                    }
                    ForEach(viewModel.tvSections) {
                        ContentListView(style: $0.style, type: MediaType.tvShow, title: $0.title, items: $0.results)
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
                .sheet(isPresented: $showWelcomeScreen) {
                    WelcomeView()
                }
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
