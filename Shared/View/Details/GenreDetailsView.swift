//
//  GenreDetailsView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 01/05/22.
//

import SwiftUI

struct GenreDetailsView: View {
    var genre: Genre
    var media: MediaType
    @StateObject private var viewModel: GenreDetailsViewModel
    @State private var isLoading: Bool = true
    @State private var showConfirmation: Bool = false
    init(genre: Genre, media: MediaType) {
        self.genre = genre
        self.media = media
        _viewModel = StateObject(wrappedValue: GenreDetailsViewModel(id: genre.id, type: media))
    }
    var columns: [GridItem] = [
        GridItem(.adaptive(minimum: UIDevice.isIPad ? 240 : 160 ))
    ]
    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    if let content = viewModel.items {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(content) { item in
                                NavigationLink(destination: ContentDetailsView(title: item.itemTitle, id: item.id, type: item.itemContentMedia)) {
                                    ItemContentFrameView(item: item, showConfirmation: $showConfirmation)
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
                .navigationTitle(genre.name!)
            }
            ConfirmationDialogView(showConfirmation: $showConfirmation)
        }
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
    private static let genre = Genre(id: 28, name: NSLocalizedString("Action", comment: ""))
    static var previews: some View {
        GenreDetailsView(genre: genre, media: .movie)
    }
}
