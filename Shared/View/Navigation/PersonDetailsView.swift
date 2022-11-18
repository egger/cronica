//
//  PersonDetailsView.swift
//  Story
//
//  Created by Alexandre Madeira on 29/01/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct PersonDetailsView: View {
    let name: String
    let personUrl: URL
    @State private var isLoading = true
    @StateObject private var viewModel: PersonDetailsViewModel
    @State private var showConfirmation = false
    @State private var scope: WatchlistSearchScope = .noScope
    @AppStorage("newBackgroundStyle") private var newBackgroundStyle = false
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
                            PersonImageView(url: viewModel.person?.personImage,
                                            name: name)
                            .frame(width: DrawingConstants.padImageWidth, height: DrawingConstants.padImageHeight)
                            .shadow(radius: DrawingConstants.imageShadow)
                            .padding([.horizontal, .top])
                            
                            OverviewBoxView(overview: viewModel.person?.personBiography,
                                            title: name,
                                            type: .person)
                            .frame(width: 500)
                            .padding(.horizontal)
                        }
                        
                        VStack {
                            PersonImageView(url: viewModel.person?.personImage,
                                            name: name)
                            .frame(width: DrawingConstants.imageWidth, height: DrawingConstants.imageHeight)
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
            .searchScopes($scope) {
                ForEach(WatchlistSearchScope.allCases) { scope in
                    Text(scope.localizableTitle).tag(scope)
                }
            }
            .autocorrectionDisabled(true)
            .navigationTitle(name)
            .toolbar {
                ToolbarItem {
                    ShareLink(item: personUrl)
                }
            }
            .background {
                if newBackgroundStyle {
                    ZStack {
                        WebImage(url: viewModel.person?.personImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .ignoresSafeArea()
                            .padding(.zero)
                        Rectangle()
                            .fill(.regularMaterial)
                            .ignoresSafeArea()
                            .padding(.zero)
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
#if os(iOS)
            .searchable(text: $viewModel.query, placement: .automatic)
#endif
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
    static let imageWidth: CGFloat = 150
    static let imageHeight: CGFloat = 150
    static let padImageWidth: CGFloat = 250
    static let padImageHeight: CGFloat = 250
}
