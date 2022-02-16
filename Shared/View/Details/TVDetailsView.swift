//
//  TVDetailsView.swift
//  Story
//
//  Created by Alexandre Madeira on 15/02/22.
//

import SwiftUI

struct TVDetailsView: View {
    let title: String
    let id: Int
    @StateObject private var viewModel = TVDetailsViewModel()
    @State private var showingOverview: Bool = false
    var body: some View {
        ScrollView {
            if let content = viewModel.tvShow {
                VStack {
                    DetailsImageView(url: content.backdropImage,
                                     title: content.title)
                    WatchlistButtonView(title: content.title,
                                        id: content.id,
                                        image: content.backdropImage,
                                        status: content.status ?? "",
                                        notify: false,
                                        type: 1)
                    AboutView(overview: content.overview ?? "")
                        .onTapGesture {
                            showingOverview.toggle()
                        }
                        .sheet(isPresented: $showingOverview) {
                            NavigationView {
                                ScrollView {
                                    Text(content.overview ?? "")
                                        .padding()
                                }
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
                    if !content.credits.isEmpty {
                        PersonListView(credits: content.credits!)
                    }
                    if !content.similar.isEmpty {
                        TVListView(style: StyleType.poster, title: "Similar", series: content.similar?.results)
                    }
                }
            }
        }
        .navigationTitle(title)
        .toolbar {
            ToolbarItem {
                Button {
                    
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .task {
            load()
        }
    }
    
    @Sendable
    private func load() {
        Task {
            await self.viewModel.load(id: id)
        }
    }
}

//struct TVDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        TVDetailsView()
//    }
//}
