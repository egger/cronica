//
//  PersonView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 03/08/22.
//

import SwiftUI

struct PersonView: View {
    let id: Int
    let name: String
    let url: URL
    @StateObject private var viewModel: PersonDetailsViewModel
    init(id: Int, name: String) {
        self.id = id
        self.name = name
        _viewModel = StateObject(wrappedValue: PersonDetailsViewModel(id: id))
        self.url = URL(string: "https://www.themoviedb.org/\(MediaType.person.rawValue)/\(id)")!
    }
    var body: some View {
        VStack {
            ScrollView {
                PersonImageView(url: viewModel.person?.personImage, name: name)
                    .frame(width: DrawingConstants.imageWidth,
                           height: DrawingConstants.imageHeight)
                    .padding()
                
                ShareLink(item: url)
                    .padding(.bottom)
                
                FilmographyListView(items: viewModel.credits)
                
                CompanionTextView()
                
                AttributionView()
                    .padding(.bottom)
            }
        }
        .navigationTitle(name)
        .task {
            await viewModel.load()
        }
    }
    
}

struct PersonView_Previews: PreviewProvider {
    static var previews: some View {
        PersonView(id: Person.previewCast.id,
                   name: Person.previewCast.name)
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 100
    static let imageHeight: CGFloat = 100
}
