//
//  ItemContentDetails.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 27/10/22.
//

import SwiftUI

struct ItemContentDetails: View {
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
        ScrollView {
            ItemContentHeaderView(title: title)
                .environmentObject(viewModel)
            VStack {
                ScrollView {
                    ItemContentList(items: viewModel.recommendations,
                                    title: "Recommendations",
                                    subtitle: "You may like",
                                    image: "film.stack")
                    CastListView(credits: viewModel.credits)
                    InfoSection(item: viewModel.content)
                        .padding([.top, .bottom])
                    AttributionView()
                }
            }
            .navigationDestination(for: Person.self) { person in
                PersonDetailsView(title: person.name, id: person.id)
            }
            .task {
                await viewModel.load()
            }
        }
        .ignoresSafeArea()
    }
}
