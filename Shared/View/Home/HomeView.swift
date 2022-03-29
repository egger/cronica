//
//  HomeView.swift
//  Story
//
//  Created by Alexandre Madeira on 10/02/22.
//

import SwiftUI

struct HomeView: View {
    static let tag: String? = "Home"
    @AppStorage("showOnboarding") var displayOnboard = true
    @StateObject private var viewModel: HomeViewModel
    @State private var showAccount: Bool = false
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: WatchlistItem.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \WatchlistItem.status, ascending: true),
        ],
        predicate: NSPredicate(format: "status == %@", "Post Production")
    )
    var items: FetchedResults<WatchlistItem>
    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel())
    }
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    if !items.isEmpty {
                        HStack {
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
                            Spacer()
                            Image(systemName: "rectangle.stack")
                                .foregroundColor(.secondary)
                                .padding()
                        }
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(items) { item in
                                    NavigationLink(destination: DetailsView(title: item.itemTitle, id: item.itemId, type: item.itemMedia)) {
                                        PosterView(title: item.itemTitle, url: item.poster)
                                            .padding([.leading, .trailing], 4)
                                    }
                                    .padding(.leading, item.id == self.items.first!.id ? 16 : 0)
                                    .padding(.trailing, item.id == self.items.last!.id ? 16 : 0)
                                    .padding([.top, .bottom])
                                }
                            }
                        }
                    }
                    if !viewModel.trendingSection.isEmpty {
                        HStack {
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
                            Spacer()
                            Image(systemName: "crown")
                                .foregroundColor(.secondary)
                                .padding()
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
