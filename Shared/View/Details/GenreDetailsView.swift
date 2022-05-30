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
    @State private var shareItems: [Any] = []
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
                                    VStack {
                                        AsyncImage(url: item.cardImageMedium,
                                                   transaction: Transaction(animation: .easeInOut)) { phase in
                                            if let image = phase.image {
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .transition(.opacity)
                                            } else if phase.error != nil {
                                                ZStack {
                                                    Rectangle().fill(.thickMaterial)
                                                    VStack {
                                                        Text(item.itemTitle)
                                                            .font(.callout)
                                                            .lineLimit(1)
                                                            .padding(.bottom)
                                                        Image(systemName: "film")
                                                    }
                                                    .padding()
                                                    .foregroundColor(.secondary)
                                                }
                                            } else {
                                                ZStack {
                                                    Rectangle().fill(.thickMaterial)
                                                    VStack {
                                                        ProgressView()
                                                            .padding(.bottom)
                                                        Image(systemName: "film")
                                                    }
                                                    .padding()
                                                    .foregroundColor(.secondary)
                                                }
                                            }
                                        }
                                        .frame(width: UIDevice.isIPad ? DrawingConstants.padImageWidth :  DrawingConstants.imageWidth,
                                               height: UIDevice.isIPad ? DrawingConstants.padImageHeight : DrawingConstants.imageHeight)
                                        .clipShape(RoundedRectangle(cornerRadius: UIDevice.isIPad ? DrawingConstants.padImageRadius : DrawingConstants.imageRadius,
                                                                    style: .continuous))
                                        .contextMenu {
                                            Button(action: {
                                                shareItems = [item.itemURL]
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
                                        HStack {
                                            Text(item.itemTitle)
                                                .font(.caption)
                                                .lineLimit(DrawingConstants.titleLineLimit)
                                            Spacer()
                                        }
                                        .frame(width: UIDevice.isIPad ? DrawingConstants.padImageWidth : DrawingConstants.imageWidth)
                                    }
                                    .sheet(isPresented: $isSharePresented,
                                           content: { ActivityViewController(itemsToShare: $shareItems) })
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

private struct DrawingConstants {
    static let imageWidth: CGFloat = 160
    static let imageHeight: CGFloat = 100
    static let imageRadius: CGFloat = 8
    static let padImageWidth: CGFloat = 240
    static let padImageHeight: CGFloat = 140
    static let padImageRadius: CGFloat = 12
    static let titleLineLimit: Int = 1
}
