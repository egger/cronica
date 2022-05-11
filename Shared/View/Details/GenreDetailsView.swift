//
//  GenreDetailsView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 01/05/22.
//

import SwiftUI

struct GenreDetailsView: View {
    var genreID: Int
    var genreName: String
    var genreType: MediaType
    @StateObject private var viewModel: GenreDetailsViewModel
    @State private var isLoading: Bool = true
    init(genreID: Int, genreName: String, genreType: MediaType) {
        self.genreID = genreID
        self.genreName = genreName
        self.genreType = genreType
        _viewModel = StateObject(wrappedValue: GenreDetailsViewModel(id: genreID, type: genreType))
    }
    var columns: [GridItem] = [
        GridItem(.adaptive(minimum: UIDevice.isIPad ? 240 : 160 ))
    ]
    var body: some View {
        ScrollView {
            if let content = viewModel.items {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(content) { item in
                        NavigationLink(destination: ContentDetailsView(title: item.itemTitle, id: item.id, type: item.itemContentMedia)) {
                            StillFrameView(image: item.cardImageMedium,
                                           title: item.itemTitle)
                            .contextMenu {
                                Button(action: {
                                    
                                }, label: {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                })
                                Button(action: {
                                    
                                }, label: {
                                    Label("Add to watchlist", systemImage: "plus.square" )
                                })
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    if viewModel.startPagination || !viewModel.endPagination {
                        ProgressView()
                            .padding()
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    viewModel.loadMoreItems()
                                }
                            }
                    }
                }
                .padding()
                if viewModel.endPagination {
                    HStack {
                        Spacer()
                        Text("This is the end.")
                            .padding()
                            .font(.callout)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                AttributionView()
            } else {
                ProgressView()
            }
        }
        .task {
            load()
        }
        .redacted(reason: isLoading ? .placeholder : [] )
        .navigationTitle(genreName)
    }
    
    @Sendable
    private func load() {
        Task {
            viewModel.loadMoreItems()
            withAnimation {
                isLoading = false
            }
        }
    }
}

struct GenreDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        GenreDetailsView(genreID: 28, genreName: "Action", genreType: .movie)
    }
}
