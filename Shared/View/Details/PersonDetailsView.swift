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
    @State private var showImageFullscreen = false
    @State private var showSaveConfirmation = false
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
                            imageProfile
                                .padding([.horizontal, .top])
                            
                            OverviewBoxView(overview: viewModel.person?.personBiography,
                                            title: name,
                                            type: .person)
                            .frame(width: 500)
                            .padding(.horizontal)
                        }
                        
                        VStack {
                            imageProfile
                                .padding()
                            
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
                TranslucentBackground(image: viewModel.person?.personImage)
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
#elseif os(macOS)
            .searchable(text: $viewModel.query)
#endif
            ConfirmationDialogView(showConfirmation: $showConfirmation)
        }
    }
    
    private func load() {
        Task {
            await self.viewModel.load()
            if viewModel.isLoaded {
                DispatchQueue.main.async {
                    withAnimation {
                        isLoading = false
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var search: some View {
        if !viewModel.query.isEmpty {
#if os(iOS)
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
#else
            Table(viewModel.credits.filter { ($0.itemTitle.localizedStandardContains(viewModel.query)) as Bool }) {
                TableColumn("Title") { item in
                    SearchItemView(item: item, showInformationPopup: $showInformationPopup)
                        .buttonStyle(.plain)
                        .accessibilityHint(Text(item.itemTitle))
                }
            }
#endif     
        }
    }
    
    private var imageProfile: some View {
        WebImage(url: viewModel.person?.personImage)
            .resizable()
            .placeholder {
                Rectangle().redacted(reason: .placeholder)
                    .clipShape(Circle())
            }
            .aspectRatio(contentMode: .fill)
            .transition(.opacity)
            .clipShape(Circle())
            .frame(width: DrawingConstants.imageWidth, height: DrawingConstants.imageHeight)
            .shadow(radius: DrawingConstants.imageShadow)
            .accessibilityHidden(true)
    }
}

struct CastDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        PersonDetailsView(title: Person.previewCast.name,
                          id: Person.previewCast.id)
    }
}

private struct DrawingConstants {
#if os(macOS)
    static let imageWidth: CGFloat = 250
    static let imageHeight: CGFloat = 250
#else
    static let imageWidth: CGFloat = UIDevice.isIPad ? 250 : 150
    static let imageHeight: CGFloat = UIDevice.isIPad ? 250 : 150
#endif
    static let imageShadow: CGFloat = 6
}
