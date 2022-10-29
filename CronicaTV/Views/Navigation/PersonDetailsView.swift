//
//  PersonDetailsView.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 28/10/22.
//

import SwiftUI
import SDWebImageSwiftUI

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
        ScrollView {
            VStack {
                HStack {
                    WebImage(url: viewModel.person?.personImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                    Text(name)
                        .font(.title2)
                }
                .padding()
                if !viewModel.credits.isEmpty {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.credits) { item in
                            ItemContentCardView(item: item)
                        }
                    }
                } else {
                    Spacer()
                    Text("No Filmography.")
                    Spacer()
                }
            }
            .task {
                await viewModel.load()
            }
        }
    }
}

struct PersonDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        PersonDetailsView(title: Person.previewCast.name, id: Person.previewCast.id)
    }
}
