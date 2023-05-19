//
//  ItemContentPhoneView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 19/05/23.
//

import SwiftUI
#if os(iOS)
struct ItemContentPhoneView: View {
    let title: String
    let type: MediaType
    let id: Int
    @Binding var showConfirmation: Bool
    @EnvironmentObject var viewModel: ItemContentViewModel
    var body: some View {
        VStack {
            CoverImageView(title: title)
                .environmentObject(viewModel)
            DetailWatchlistButton()
                .keyboardShortcut("l", modifiers: [.option])
                .environmentObject(viewModel)

            OverviewBoxView(overview: viewModel.content?.itemOverview,
                            title: title)
            .padding()
            
            TrailerListView(trailers: viewModel.content?.itemTrailers)
            
            if let seasons = viewModel.content?.itemSeasons {
                SeasonList(showID: id, numberOfSeasons: seasons).padding(0)
            }
            
            WatchProvidersList(id: id, type: type)
            
            CastListView(credits: viewModel.credits)
            
            ItemContentListView(items: viewModel.recommendations,
                                title: "Recommendations",
                                subtitle: "You may like",
                                image: nil,
                                addedItemConfirmation: $showConfirmation,
                                displayAsCard: true)
            
            InformationSectionView(item: viewModel.content)
                .padding()
            
            AttributionView()
                .padding([.top, .bottom])
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.automatic)
    }
}

struct ItemContentPhoneView_Previews: PreviewProvider {
    static var previews: some View {
        ItemContentPhoneView(title: "Preview", type: .movie, id: ItemContent.example.id, showConfirmation: .constant(false))
    }
}
#endif
