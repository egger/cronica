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
    @State private var showingOverview: Bool = false
    var body: some View {
        ScrollView {
            if let tvShow = viewModel.tvShow {
                VStack {
                    DetailsImageView(image: tvShow.backdropImage, placeholderTitle: tvShow.title)
                        .padding(.horizontal)
                    WatchlistButtonView(title: tvShow.title, id: tvShow.id, image: tvShow.backdropImage, status: tvShow.status ?? "", notify: false, type: "TV Show")
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


