//
//  SearchView.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 27/10/22.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var showConfirmation = false
    var body: some View {
        VStack {
            switch viewModel.stage {
            case .none:
                VStack {
                    Spacer()
                    AttributionView()
                }
            case .searching:
                ProgressView("Searching")
                    .foregroundColor(.secondary)
                    .padding()
            case .empty:
                Label("No Results", systemImage: "minus.magnifyingglass")
                    .font(.title)
                    .foregroundColor(.secondary)
            case .failure:
                VStack {
                    Label("Search failed, try again later.", systemImage: "text.magnifyingglass")
                }
            case .success:
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(viewModel.items) { item in
                            NavigationLink(value: item) {
                                RectangularItemContentView(item: item)
                            }
                            .ignoresSafeArea(.all)
                            .buttonStyle(.card)
                        }
                        if viewModel.startPagination && !viewModel.endPagination {
                            ProgressView()
                                .padding()
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        viewModel.loadMoreItems()
                                    }
                                }

                        }
                    }
                }
            }
        }
        .searchable(text: $viewModel.query, prompt: "Movies, Shows, People")
        .task(id: viewModel.query) {
            await viewModel.search(viewModel.query)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}

struct SearchItemView: View {
    let item: ItemContent
    @State private var showConfirmation = false
    var body: some View {
        if item.media == .person {
            NavigationLink(value: item) {
                profile
            }
            .ignoresSafeArea(.all)
            .buttonStyle(.card)
        } else {
            PosterView(item: item, addedItemConfirmation: $showConfirmation)
        }
    }
    private var profile: some View {
        AsyncImage(url: item.itemImage,
                   transaction: Transaction(animation: .easeInOut)) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .transition(.opacity)
            } else if phase.error != nil {
                ZStack {
                    ProgressView()
                }.background(.secondary)
            } else {
                ZStack {
                    Color.secondary
                    Image(systemName: "person")
                }
            }
        }
                   .frame(width: DrawingConstants.personImageWidth,
                          height: DrawingConstants.personImageHeight)
                   .clipShape(Circle())
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 70
    static let imageHeight: CGFloat = 50
    static let imageRadius: CGFloat = 4
    static let textLimit: Int = 1
    static let personImageWidth: CGFloat = 60
    static let personImageHeight: CGFloat = 60
}
