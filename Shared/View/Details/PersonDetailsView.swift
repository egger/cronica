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
    
    #if os(iOS)
    private var downloadButton: some View {
        Button {
            guard let imageUrl = viewModel.person?.originalPersonImage else { return }
            Task {
                let data = await NetworkService.shared.downloadImageData(from: imageUrl)
                guard let data else { return }
                let image = UIImage(data: data)
                guard let image else { return }
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                showSaveConfirmation.toggle()
            }
        } label: {
            Label("Save Image", systemImage: "square.and.arrow.down")
        }
    }
    #endif
    
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
    
    private var imageProfile: some View {
        AsyncImage(url: viewModel.person?.personImage) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if phase.error != nil {
                Rectangle().redacted(reason: .placeholder)
            } else {
                ZStack {
                    Rectangle().fill(.gray.gradient)
                    ProgressView()
                }
            }
        }
        .clipShape(Circle())
        .frame(width: DrawingConstants.imageWidth, height: DrawingConstants.imageHeight)
        .shadow(radius: DrawingConstants.imageShadow)
        .accessibilityHidden(true)
        .buttonStyle(.plain)
        .padding([.top, .bottom])
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
