//
//  ItemContentDetails.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 27/10/22.
//

import SwiftUI
#if os(tvOS)
struct TVItemContentDetails: View {
    var title: String
    var id: Int
    var type: MediaType
    @StateObject private var viewModel: ItemContentViewModel
    init(title: String, id: Int, type: MediaType) {
        _viewModel = StateObject(wrappedValue: ItemContentViewModel(id: id, type: type))
        self.title = title
        self.id = id
        self.type = type
    }
    var body: some View {
        ZStack {
            ScrollView {
                TVItemContentHeaderView(title: title)
                    .environmentObject(viewModel)
                    .redacted(reason: viewModel.isLoading ? .placeholder : [])
                VStack {
                    ScrollView {
                        TVSeasonListView(numberOfSeasons: viewModel.content?.itemSeasons,
                                       id: self.id, inWatchlist: $viewModel.isInWatchlist)
                        TVItemContentList(items: viewModel.recommendations,
                                        title: "Recommendations",
                                        subtitle: "You may like",
                                        image: "film.stack")
                        TVCastListView(credits: viewModel.credits)
                        TVInfoSection(item: viewModel.content)
                            .padding([.top, .bottom])
                        AttributionView()
                    }
                }
                .task { await viewModel.load() }
                .redacted(reason: viewModel.isLoading ? .placeholder : [])
            }
            .ignoresSafeArea()
            .background {
                TranslucentBackground(image: viewModel.content?.cardImageLarge)
            }
        }
    }
}
#endif
