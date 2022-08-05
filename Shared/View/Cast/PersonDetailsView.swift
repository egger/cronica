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
    let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 160 ))
    ]
    init(title: String, id: Int) {
        _viewModel = StateObject(wrappedValue: PersonDetailsViewModel(id: id))
        self.name = title
        self.personUrl = URL(string: "https://www.themoviedb.org/\(MediaType.person.rawValue)/\(id)")!
    }
    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    ViewThatFits {
                        HStack {
                            ProfileImageView(url: viewModel.person?.personImage,
                                             name: name)
                            .shadow(radius: DrawingConstants.imageShadow)
                            .padding(.horizontal)
                            
                            OverviewBoxView(overview: viewModel.person?.personBiography,
                                            title: name,
                                            type: .person)
                            .frame(minWidth: 500)
                            .padding(.horizontal)
                        }
                        
                        VStack {
                            ProfileImageView(url: viewModel.person?.personImage,
                                             name: name)
                            .shadow(radius: DrawingConstants.imageShadow)
                            .padding(.horizontal)
                            
                            OverviewBoxView(overview: viewModel.person?.personBiography,
                                            title: name,
                                            type: .person)
                            .padding()
                        }
                    }
                    
                    FilmographyListView(filmography: viewModel.credits,
                                        showConfirmation: $showConfirmation)
                    .padding(.horizontal)
                    
                    AttributionView()
                        .padding([.top, .bottom])
                        .unredacted()
                }
            }
            .task { load() }
            .redacted(reason: isLoading ? .placeholder : [])
            .overlay(searchOverlay)
            .searchable(text: $viewModel.query)
            .autocorrectionDisabled(true)
            .navigationTitle(name)
            .toolbar {
                ToolbarItem {
                    HStack {
                        Button(action: {
                            viewModel.updateFavorite()
                        }, label: {
                            Label(viewModel.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                                  systemImage: viewModel.isFavorite ? "star.slash.fill" : "star")
                        })
                        ShareLink(item: personUrl)
                    }
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
    
    @ViewBuilder
    private var searchOverlay: some View {
        if viewModel.query != "" {
            List {
                if let credits = viewModel.credits {
                    ForEach(credits.filter { ($0.itemTitle.localizedStandardContains(viewModel.query)) as Bool }) { item in
                        SearchItemView(item: item, showConfirmation: $showConfirmation)
                    }
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
