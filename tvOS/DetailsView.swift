//
//  DetailsView.swift
//  Story (tvOS)
//
//  Created by Alexandre Madeira on 13/03/22.
//

import SwiftUI

struct DetailsView: View {
    var title: String
    var id: Int
    var type: MediaType
    @StateObject private var viewModel: ContentDetailsViewModel
    init(title: String, id: Int, type: MediaType) {
        _viewModel = StateObject(wrappedValue: ContentDetailsViewModel())
        self.title = title
        self.id = id
        self.type = type
    }
    var body: some View {
        NavigationView {
            if let content = viewModel.content {
                VStack {
                    HStack {
                        Text(content.itemTitle)
                            .font(.title)
                            .padding()
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        VStack {
                            Text(content.itemTitle)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding()
                            if !content.itemInfo.isEmpty {
                                Text(content.itemInfo)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Divider().padding()
                            Button {
                                if !viewModel.inWatchlist {
                                    viewModel.add(notify: true)
                                } else {
                                    viewModel.remove()
                                }
                            } label: {
                                Text(!viewModel.inWatchlist ? "Add to watchlist" : "Remove from watchlist")
                            }
                            .buttonStyle(.bordered)
                            .padding()
                        }
                        VStack {
                            Text(content.itemAbout)
                                .padding([.top], 2)
                                .padding()
                        }
                    }
                    .background {
                        ZStack {
                            Rectangle()
                                .padding(0)
                                .background(.ultraThinMaterial)
                            Rectangle()
                                .padding(0)
                                .background(.ultraThinMaterial)
                                .mask {
                                    LinearGradient(gradient: Gradient(colors:
                                                                        [.black,
                                                                         .black.opacity(0)]),
                                                   startPoint: .center,
                                                   endPoint: .top)
                                }
                        }
                        .padding(0)
                    }
                }
                .background {
                    ZStack {
                        AsyncImage(url: content.cardImageOriginal) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView(title)
                        }
                        .ignoresSafeArea(.all)
                    }
                }
            }
        }
        .ignoresSafeArea(.all)
        .task {
            load()
        }
    }
    @Sendable
    private func load() {
        Task {
            await self.viewModel.load(id: self.id, type: self.type)
        }
    }
}

struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsView(title: Content.previewContent.itemTitle,
                    id: Content.previewContent.id,
                    type: MediaType.movie)
    }
}

private struct DrawingConstants {
    static let panelWidth: CGFloat = 500
    static let panelHeight: CGFloat = 640
    static let shadowRadius: CGFloat = 5
    static let shadowOpacity: Double = 0.5
}
