//
//  PersonDetailsView.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 28/10/22.
//

import SwiftUI

struct PersonDetailsView: View {
    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 360))
    ]
    let name: String
    @State private var isLoading = true
    @StateObject private var viewModel: PersonDetailsViewModel
    init(title: String, id: Int) {
        _viewModel = StateObject(wrappedValue: PersonDetailsViewModel(id: id))
        self.name = title
    }
    var body: some View {
        VStack {
            if !viewModel.credits.isEmpty {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.credits) { item in
                            ItemContentCardView(item: item)
                        }
                    }
                }
            } else {
                Spacer()
                Text("This list is empty.")
                Spacer()
            }
        }
        .navigationTitle(name)
        .task {
            await viewModel.load()
        }
    }
}

struct PersonDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        PersonDetailsView(title: Person.previewCast.name, id: Person.previewCast.id)
    }
}
