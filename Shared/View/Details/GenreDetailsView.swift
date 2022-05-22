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
    @State private var showConfirmation: Bool = false
    private let context = DataController.shared
    @State private var isSharePresented: Bool = false
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
        ZStack {
            VStack {
                ScrollView {
                    if let content = viewModel.items {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(content) { item in
                                NavigationLink(destination: ContentDetailsView(title: item.itemTitle, id: item.id, type: item.itemContentMedia)) {
                                    StillFrameView(image: item.cardImageMedium,
                                                   title: item.itemTitle)
                                    .contextMenu {
                                        Button(action: {
                                            isSharePresented.toggle()
                                        }, label: {
                                            Label("Share",
                                                  systemImage: "square.and.arrow.up")
                                        })
                                        Button(action: {
                                            Task {
                                                await updateWatchlist(item: item)
                                            }
                                        }, label: {
                                            Label("Add to watchlist", systemImage: "plus.circle")
                                        })
                                    }
//                                    .sheet(isPresented: $isSharePresented,
//                                           content: { ActivityViewController(itemsToShare: [item.itemURL]) })
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
            VStack {
                Spacer()
                HStack {
                    Label("Added to watchlist", systemImage: "checkmark.circle")
                        .tint(.green)
                        .padding()
                }
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .padding()
                .shadow(radius: 6)
                .opacity(showConfirmation ? 1 : 0)
                .scaleEffect(showConfirmation ? 1.1 : 1)
                .animation(.linear, value: showConfirmation)
            }
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
    
    private func updateWatchlist(item: Content) async {
        HapticManager.shared.softHaptic()
        if !context.isItemInList(id: item.id, type: self.genreType) {
            let content = try? await NetworkService.shared.fetchContent(id: item.id, type: self.genreType)
            if let content = content {
                context.saveItem(content: content, notify: content.itemCanNotify)
                withAnimation {
                    showConfirmation.toggle()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        showConfirmation = false
                    }
                }
            }
        }
    }
}

struct GenreDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        GenreDetailsView(genreID: 28, genreName: "Action", genreType: .movie)
    }
}
