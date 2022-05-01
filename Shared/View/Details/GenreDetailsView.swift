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
    @StateObject private var viewModel: GenreDetailsViewModel
    @State private var isLoading: Bool = false
    init(genreID: Int, genreName: String) {
        self.genreID = genreID
        _viewModel = StateObject(wrappedValue: GenreDetailsViewModel(id: genreID))
        self.genreName = genreName
    }
    var columns: [GridItem] = [
        GridItem(.adaptive(minimum: 160))
    ]
    var body: some View {
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
                                .frame(width: 160, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                HStack {
                                    Text(item.itemTitle)
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                        .lineLimit(1)
                                        .padding(.leading)
                                    Spacer()
                                }
                            }
                        }
                    }
                    if viewModel.startPagination || !viewModel.endPagination {
                        ProgressView()
                            .offset(y: -15)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    viewModel.updateItems(id: genreID)
                                }
                            }
                    }
                }
                .padding()
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    
                }, label: {
                    Label("Order", systemImage: "line.3.horizontal.decrease.circle")
                })
            }
        }
    }
    
    @Sendable
    private func load() {
        Task {
           // await viewModel.fetch(id: self.genreID)
//            await self.viewModel.load(id: self.genreID)
//            if viewModel.content != nil {
//                withAnimation {
//                    isLoading = false
//                }
//            }
        }
    }
}

struct GenreDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        GenreDetailsView(genreID: 28, genreName: "Action")
    }
}
