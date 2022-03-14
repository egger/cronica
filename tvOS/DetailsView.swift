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
    @StateObject private var viewModel = ContentDetailsViewModel()
    var body: some View {
        NavigationView {
            if let content = viewModel.content {
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
                        ScrollView {
                            Text(content.itemAbout)
                                .lineLimit(3)
                                .padding([.top], 2)
                                .padding()
                        }
                        Button {
                            if !viewModel.inWatchlist {
                                viewModel.add(notify: true)
                            } else {
                                viewModel.remove()
                            }
                        } label: {
                            Label(!viewModel.inWatchlist ? "Add to watchlist" : "Remove", systemImage: !viewModel.inWatchlist ? "plus.square" : "minus.square")
                        }
                        .buttonStyle(.bordered)
                        .tint(viewModel.inWatchlist ? .red : .blue)
                        .padding()
                    }
                    .background(.regularMaterial)
                    .frame(width: 400,  height: 500)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding()
                    Spacer()
                    Spacer()
                }
                .background {
                    AsyncImage(url: content.cardImageOriginal) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        VStack {
                            ProgressView(title)
                        }.background(Color.secondary)
                    }
                    .ignoresSafeArea(.all)
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

//struct DetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailsView()
//    }
//}
