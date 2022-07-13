//
//  PersonDetailsView.swift
//  Story
//
//  Created by Alexandre Madeira on 29/01/22.
//

import SwiftUI

struct PersonDetailsView: View {
    let name: String
    let personUrl: URL
    @State private var isLoading = true
    @StateObject private var viewModel: PersonDetailsViewModel
    @State private var showConfirmation = false
    init(title: String, id: Int) {
        _viewModel = StateObject(wrappedValue: PersonDetailsViewModel(id: id))
        self.name = title
        self.personUrl = URL(string: "https://www.themoviedb.org/\(MediaType.person.rawValue)/\(id)")!
    }
    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    ProfileImageView(url: viewModel.person?.personImage,
                                     name: name)
                    .shadow(radius: DrawingConstants.imageShadow)
                    
                    OverviewBoxView(overview: viewModel.person?.biography,
                                    title: name,
                                    type: .person)
                    .padding()
                    
                    ItemContentListView(items: viewModel.credits,
                                        title: "Filmography",
                                        subtitle: "Know for",
                                        image: "list.and.film",
                                        addedItemConfirmation: $showConfirmation)
                    
                    AttributionView()
                        .padding([.top, .bottom])
                        .unredacted()
                }
            }
            .task { load() }
            .redacted(reason: isLoading ? .placeholder : [])
            .navigationTitle(name)
            .toolbar {
                ToolbarItem {
                    ShareLink(item: personUrl)
                }
            }
            ConfirmationDialogView(showConfirmation: $showConfirmation)
        }
    }
    
    private func load() {
        Task {
            await self.viewModel.load()
            if viewModel.isLoaded {
                withAnimation {
                    isLoading = false
                }
            }
        }
    }
}

struct CastDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        PersonDetailsView(title: Credits.previewCast.name,
                          id: Credits.previewCast.id)
    }
}

private struct DrawingConstants {
    static let imageShadow: CGFloat = 6
}
