//
//  HomeView.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 27/10/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @State private var showConfirmation = false
    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel())
    }
    var body: some View {
        ZStack {
            if !viewModel.isLoaded {
                ProgressView()
            }
            VStack {
                ScrollView {
                    ItemContentListView(items: viewModel.trending,
                                        title: "Trending",
                                        subtitle: "Today",
                                        image: "crown",
                                        addedItemConfirmation: $showConfirmation)
                    ForEach(viewModel.sections) { section in
                        ItemContentListView(items: section.results,
                                            title: section.title,
                                            subtitle: section.subtitle,
                                            image: section.image,
                                            addedItemConfirmation: $showConfirmation)
                    }
                    AttributionView()
                }
            }
            .task {
                await viewModel.load()
            }
            .redacted(reason: !viewModel.isLoaded ? .placeholder : [] )
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

struct PosterView: View {
    let item: ItemContent
    private let context = PersistenceController.shared
    @State private var isInWatchlist = false
    @State private var isWatched = false
    @Binding var addedItemConfirmation: Bool
    var body: some View {
        NavigationLink(value: item) {
            WebImage(url: item.posterImageMedium)
                .resizable()
                .placeholder {
                    VStack {
                        Text(item.itemTitle)
                            .lineLimit(1)
                            .padding(.bottom)
                        Image(systemName: "film")
                    }
                    .frame(width: DrawingConstants.posterWidth,
                           height: DrawingConstants.posterHeight)
                    .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.posterRadius,
                                                style: .continuous))
                    .ignoresSafeArea(.all)
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
                .aspectRatio(contentMode: .fill)
                .transition(.opacity)
                .frame(width: DrawingConstants.posterWidth,
                       height: DrawingConstants.posterHeight)
                .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.posterRadius,
                                            style: .continuous))
                .padding(.zero)
                .hoverEffect(.lift)
                .modifier(
                    ItemContentContextMenu(item: item,
                                           showConfirmation: $addedItemConfirmation,
                                           isInWatchlist: $isInWatchlist,
                                           isWatched: $isWatched)
                )
                .task {
                    withAnimation {
                        isInWatchlist = context.isItemSaved(id: item.id, type: item.itemContentMedia)
                        if isInWatchlist && !isWatched {
                            isWatched = context.isMarkedAsWatched(id: item.id, type: item.itemContentMedia)
                        }
                    }
                }
        }
        .ignoresSafeArea(.all)
        .buttonStyle(.card)
    }
}



private struct DrawingConstants {
    static let posterWidth: CGFloat = 200
    static let posterHeight: CGFloat = 310
    static let posterRadius: CGFloat = 12
    static let shadowRadius: CGFloat = 2
}
