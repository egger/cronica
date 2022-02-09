//
//  TvDetailsView.swift
//  Story
//
//  Created by Alexandre Madeira on 08/02/22.
//

import SwiftUI

struct TvDetailsView: View {
    let tvId: Int
    let tvTitle: String
    @StateObject private var viewModel = TvDetailsViewModel()
    var body: some View {
        ScrollView {
            if let tvShow = viewModel.tvShow {
                DetailsView(tvShow: tvShow)
            }
        }
        .navigationTitle(tvTitle)
        .task {
            load()
        }
    }
    
    @Sendable
    private func load() {
        Task {
            await self.viewModel.loadTvShow(id: self.tvId)
        }
    }
}

//struct TvDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        TvDetailsView()
//    }
//}

private struct DetailsView: View {
    let tvShow: TvShow
    private let generator = UIImpactFeedbackGenerator(style: .medium)
    @State private var inWatchlist: Bool = false
    @State private var showingOverview: Bool = false
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.id, ascending: true)],
        animation: .default)
    private var watchlistItems: FetchedResults<WatchlistItem>
    var body: some View {
        VStack {
            DetailsImageView(image: tvShow.backdropImage, placeholderTitle: tvShow.title)
                .padding(.horizontal)
            Button {
                #if os(iOS)
                generator.impactOccurred(intensity: 1.0)
                #endif
                if !inWatchlist {
                    withAnimation(.easeInOut) {
                        inWatchlist.toggle()
                    }
                    addItem(title: tvShow.title, id: tvShow.id, image: tvShow.backdropImage, status: tvShow.status ?? "" , notify: false)
                    
                } else {
                    withAnimation(.easeInOut) {
                        inWatchlist.toggle()
                    }
                    
                }
                
            } label: {
                withAnimation(.easeInOut) {
                    Label(!inWatchlist ? "Add to watchlist" : "Remove from watchlist", systemImage: !inWatchlist ? "plus.square" : "minus.square")
                        .padding(.horizontal)
                        .padding([.top, .bottom], 6)
                }
            }
            .buttonStyle(.bordered)
            .tint(inWatchlist ? .red : .blue)
            AboutView(overview: tvShow.overview!)
                .onTapGesture {
                    showingOverview.toggle()
                }
                .sheet(isPresented: $showingOverview) {
                    NavigationView {
                        Text(tvShow.overview!)
                            .padding()
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showingOverview.toggle()
                            }
                        }
                    }
                }
            Divider()
                .padding([.horizontal, .top])
        }
        .onAppear {
            for item in watchlistItems {
                if item.id == tvShow.id {
                    inWatchlist.toggle()
                }
            }
        }
    }
    
    private func addItem(title: String, id: Int, image: URL, status: String, notify: Bool = false) {
        withAnimation {
            var inWatchlist: Bool = false
            for i in watchlistItems {
                if i.id == tvShow.id {
                    inWatchlist = true
                }
            }
            if !inWatchlist {
                let item = WatchlistItem(context: viewContext)
                item.title = title
                item.id = Int32(id)
                item.image = image
                item.status = status
                item.type = "TV Show"
                item.notify = notify
                do {
                    try viewContext.save()
                } catch {
                    fatalError("Fatal error on adding a new item, error: \(error.localizedDescription).")
                }
            }
            
        }
    }
}
