//
//  SearchView.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 27/10/22.
//

import SwiftUI
#if os(tvOS)
struct TVSearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    var body: some View {
        VStack {
            switch viewModel.stage {
            case .none:
                VStack { }
            case .searching:
                ProgressView("Searching")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding()
            case .empty:
                ContentUnavailableView {
                    Label("No Results", systemImage: "magnifyingglass")
                }
                .padding()
            case .failure:
                VStack {
                    ContentUnavailableView {
                        Label("Search failed, try again later.", systemImage: "magnifyingglass")
                    }
                    .padding()
                }
            case .success:
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(viewModel.items) { item in
                            TVSearchItemContentView(item: item)
                                .padding([.leading, .trailing], 2)
                                .padding(.leading, item.id == viewModel.items.first?.id ? 16 : 0)
                                .padding(.trailing, item.id == viewModel.items.last?.id ? 16 : 0)
                                .padding(.vertical)
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
					.padding(.vertical)
                }
            }
        }
        .searchable(text: $viewModel.query, prompt: "Movies, Shows, People")
        .task(id: viewModel.query) {
            await viewModel.search(viewModel.query)
        }
        .navigationDestination(for: ItemContent.self) { item in
			ItemContentDetails(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
				.ignoresSafeArea(.all, edges: .horizontal)
        }
		.navigationDestination(for: SearchItemContent.self) { item in
			if item.media == .person {
				PersonDetailsView(title: item.itemTitle, id: item.id)
					.ignoresSafeArea(.all, edges: .horizontal)
			} else {
				ItemContentDetails(title: item.itemTitle, id: item.id, type: item.media)
					.ignoresSafeArea(.all, edges: .horizontal)
			}
		}
		.navigationDestination(for: Person.self) { person in
			PersonDetailsView(title: person.name, id: person.id)
				.ignoresSafeArea(.all, edges: .horizontal)
		}
    }
}

import SDWebImageSwiftUI

private struct TVSearchItemContentView: View {
    let item: SearchItemContent
    private var image: URL?
    @State private var isInWatchlist = false
    @State private var isWatched = false
    private let context = PersistenceController.shared
    @FocusState var isStackFocused: Bool
    init(item: SearchItemContent) {
        self.item = item
    }
    var body: some View {
        VStack(alignment: .leading) {
            NavigationLink(value: item) {
                WebImage(url: item.itemImage)
                    .resizable()
                    .placeholder {
                        VStack {
                            Text(item.itemTitle)
                                .lineLimit(1)
                                .padding(.bottom)
                            if item.media == .person {
                                Image(systemName: "person")
                            } else {
                                Image(systemName: "popcorn.fill")
                            }
                        }
                        .frame(width: DrawingConstants.posterWidth,
                               height: DrawingConstants.posterHeight)
                        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.posterRadius,
                                                    style: .continuous))
                    }
                    .overlay {
                        if isInWatchlist {
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    if isWatched {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.white.opacity(0.8))
                                            .padding()
                                    } else {
                                        Image(systemName: "square.stack.fill")
                                            .foregroundColor(.white.opacity(0.8))
                                            .padding()
                                    }
                                }
                                .background {
                                    Color.black.opacity(0.5)
                                        .mask {
                                            LinearGradient(colors:
                                                            [Color.black,
                                                             Color.black.opacity(0.924),
                                                             Color.black.opacity(0.707),
                                                             Color.black.opacity(0.383),
                                                             Color.black.opacity(0)],
                                                           startPoint: .bottom,
                                                           endPoint: .top)
                                        }
                                }
                            }
                        }
                    }
                    .frame(width: DrawingConstants.posterWidth,
                           height: DrawingConstants.posterHeight)
                    .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.posterRadius,
                                                style: .continuous))
                    .aspectRatio(contentMode: .fill)
                    .transition(.opacity)
                    .padding(.zero)
                    .task {
                        if item.media != .person {
                            withAnimation {
                                isInWatchlist = context.isItemSaved(id: item.itemContentID)
                                if isInWatchlist && !isWatched {
                                    isWatched = context.isMarkedAsWatched(id: item.itemContentID)
                                }
                            }
                        }
                    }
            }
            Text(item.itemTitle)
                .padding(.top, 4)
                .font(.caption)
                .lineLimit(2)
                .foregroundStyle(isStackFocused ? .primary : .secondary)
            Spacer()
        }
        .focused($isStackFocused)
        .frame(width: DrawingConstants.posterWidth)
    }
}

private struct DrawingConstants {
    static let posterWidth: CGFloat = 220
    static let posterHeight: CGFloat = 320
    static let posterRadius: CGFloat = 12
    static let shadowRadius: CGFloat = 2
}
#endif
