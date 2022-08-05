//
//  ItemContentView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 03/08/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ItemContentView: View {
    let title: String
    let itemUrl: URL
    @StateObject private var viewModel: ItemContentViewModel
    init(id: Int, title: String, mediaType: MediaType) {
        self.title = title
        _viewModel = StateObject(wrappedValue: ItemContentViewModel(id: id, type: mediaType))
        self.itemUrl = URL(string: "https://www.themoviedb.org/\(mediaType.rawValue)/\(id)")!
    }
    var body: some View {
        ScrollView {
            VStack {
                
                WebImage(url: viewModel.content?.cardImageMedium)
                    .resizable()
                    .placeholder {
                        HeroImagePlaceholder(title: title)
                    }
                    .aspectRatio(contentMode: .fill)
                    .transition(.opacity)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding()
                
                Button(action: {
                    withAnimation {
                        viewModel.isInWatchlist.toggle()
                    }
                    viewModel.update()
                    if !viewModel.isInWatchlist {
                        withAnimation {
                            viewModel.hasNotificationScheduled = viewModel.content?.itemCanNotify ?? false
                        }
                    } else {
                        withAnimation {
                            viewModel.hasNotificationScheduled.toggle()
                        }
                    }
                }, label: {
                    Label(viewModel.isInWatchlist ? "Remove from watchlist": "Add to watchlist",
                          systemImage: viewModel.isInWatchlist ? "minus.square" : "plus.square")
                })
                .buttonStyle(.borderedProminent)
                .tint(viewModel.isInWatchlist ? .red : .blue)
                .controlSize(.large)
                .disabled(viewModel.isLoading)
                .padding()
                
                ShareLink(item: itemUrl)
                    .padding([.horizontal, .bottom])
                
                if let overview = viewModel.content?.itemOverview {
                    Divider().padding(.horizontal)
                    Section {
                        Text(overview)
                    } header: {
                        HStack {
                            Label("About", systemImage: "film")
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                    .padding()
                    Divider().padding(.horizontal)
                }
                
                AttributionView()
                
            }
            .task {
                await load()
            }
            .navigationTitle(title)
        }
    }
    
    private func load() async {
        Task {  await self.viewModel.load() }
    }
}

//struct ItemContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ItemContentView()
//    }
//}


private struct HeroImagePlaceholder: View {
    let title: String
    var body: some View {
        ZStack {
            Rectangle().fill(.secondary)
            VStack {
                Text(title)
                    .lineLimit(1)
                    .padding(.bottom)
                Image(systemName: "film")
            }
            .padding()
            .foregroundColor(.secondary)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding()
    }
}

