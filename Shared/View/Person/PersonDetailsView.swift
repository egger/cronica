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
    @State private var scope: WatchlistSearchScope = .noScope
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
                            .frame(width: 500)
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
            .overlay(search)
            .searchable(text: $viewModel.query,
                        placement: UIDevice.isIPad ? .automatic : .navigationBarDrawer(displayMode: .always))
            .searchScopes($scope) {
                ForEach(WatchlistSearchScope.allCases) { scope in
                    Text(scope.localizableTitle).tag(scope)
                }
            }
            .autocorrectionDisabled(true)
            .navigationTitle(name)
            .toolbar {
                ToolbarItem {
                    HStack {
                        ShareLink(item: personUrl)
#if DEBUG
                        Button(action: {
                            print("Print object '\(name)': \(viewModel.person as Any)")
                        }, label: {
                            Label("Print object", systemImage: "curlybraces.square.fill")
                        })
                        .tint(.orange)
#endif
                    }
                }
            }
            .alert("Error",
                   isPresented: $viewModel.showErrorAlert,
                   actions: {
                Button("Cancel") {
                    
                }
                Button("Retry") {
                    Task {
                        await viewModel.load()
                    }
                }
            }, message: {
                Text(viewModel.errorMessage)
            })
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
    private var search: some View {
        if viewModel.query != "" {
            List {
                switch scope {
                case .noScope:
                    ForEach(viewModel.credits.filter { ($0.itemTitle.localizedStandardContains(viewModel.query)) as Bool }) { item in
                        SearchItemView(item: item, showConfirmation: $showConfirmation)
                    }
                case .movies:
                    ForEach(viewModel.credits.filter { ($0.itemTitle.localizedStandardContains(viewModel.query)) as Bool && $0.itemContentMedia == .movie }) { item in
                        SearchItemView(item: item, showConfirmation: $showConfirmation)
                    }
                case .shows:
                    ForEach(viewModel.credits.filter { ($0.itemTitle.localizedStandardContains(viewModel.query)) as Bool && $0.itemContentMedia == .tvShow }) { item in
                        SearchItemView(item: item, showConfirmation: $showConfirmation)
                    }
                }
            }
        }
    }
}

struct CastDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        PersonDetailsView(title: Person.previewCast.name,
                          id: Person.previewCast.id)
    }
}

private struct DrawingConstants {
    static let imageShadow: CGFloat = 6
}
