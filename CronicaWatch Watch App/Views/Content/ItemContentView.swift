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
    init(id: Int, title: String, type: MediaType) {
        self.title = title
        _viewModel = StateObject(wrappedValue: ItemContentViewModel(id: id, type: type))
        self.url = URL(string: "https://www.themoviedb.org/\(type.rawValue)/\(id)")!
    }
    var body: some View {
        VStack {
            ScrollView {
                WebImage(url: viewModel.content?.cardImageMedium)
                    .resizable()
                    .placeholder {
                        HeroImagePlaceholder(title: title)
                    }
                    .aspectRatio(contentMode: .fill)
                    .transition(.opacity)
                    .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius,
                                                style: .continuous))
                    .padding()
                
                WatchlistButtonView()
                    .environmentObject(viewModel)
                    .padding()
                
                WatchButtonView()
                    .environmentObject(viewModel)
                    .padding([.horizontal, .bottom])
                
                ShareLink(item: url)
                    .padding([.horizontal, .bottom])
                
                AboutSectionView(about: viewModel.content?.itemOverview)
                
                CompanionTextView()
                
                AttributionView()
                
            }
        }
        .task {
            await viewModel.load()
        }
        .navigationTitle(title)
        .redacted(reason: viewModel.isLoading ? .placeholder : [])
    }
}

struct ItemContentView_Previews: PreviewProvider {
    static var previews: some View {
        ItemContentView(id: ItemContent.previewContent.id,
                        title: ItemContent.previewContent.itemTitle,
                        type: ItemContent.previewContent.itemContentMedia)
    }
}

private struct DrawingConstants {
    static let imageRadius: CGFloat = 12
}
