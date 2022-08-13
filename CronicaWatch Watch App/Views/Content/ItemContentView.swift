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
    let url: URL
    @StateObject private var viewModel: ItemContentViewModel
    init(id: Int, title: String, mediaType: MediaType) {
        self.title = title
        _viewModel = StateObject(wrappedValue: ItemContentViewModel(id: id, type: mediaType))
        self.url = URL(string: "https://www.themoviedb.org/\(mediaType.rawValue)/\(id)")!
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
                
                WatchlistButtonView()
                    .environmentObject(viewModel)
                    .padding()
                
                Button(action: {
                    viewModel.update(markAsWatched: !viewModel.isWatched)
                }, label: {
                    Label(viewModel.isWatched ? "Remove from watched" : "Mark as watched",
                          systemImage: viewModel.isWatched ? "minus.circle.fill" : "checkmark.circle.fill")
                })
                .buttonStyle(.bordered)
                .tint(viewModel.isWatched ? .yellow : .green)
                .controlSize(.large)
                .disabled(viewModel.isLoading)
                .padding([.horizontal, .bottom])
                
                ShareLink(item: url)
                    .padding([.horizontal, .bottom])
                
                AboutSectionView(about: viewModel.content?.itemOverview)
                
                CompanionTextView()
                
                AttributionView()
                
            }
            .task {
                Task {
                    await viewModel.load()
                }
            }
            .navigationTitle(title)
            .redacted(reason: viewModel.isLoading ? .placeholder : [])
        }
    }
}

struct ItemContentView_Previews: PreviewProvider {
    static var previews: some View {
        ItemContentView(id: ItemContent.previewContent.id,
                        title: ItemContent.previewContent.itemTitle,
                        mediaType: ItemContent.previewContent.itemContentMedia)
    }
}
