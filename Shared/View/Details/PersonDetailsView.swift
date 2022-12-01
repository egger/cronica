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
                                .frame(width: DrawingConstants.padImageWidth,
                                       height: DrawingConstants.padImageHeight)
                                .shadow(radius: DrawingConstants.imageShadow)
                                .padding([.horizontal, .top])
                                .onTapGesture {
                                    showImageFullscreen = true
                                }
                            
                            OverviewBoxView(overview: viewModel.person?.personBiography,
                                            title: name,
                                            type: .person)
                            .frame(width: 500)
                            .padding(.horizontal)
                        }
                        
                        VStack {
                            imageProfile
                                .frame(width: DrawingConstants.imageWidth, height: DrawingConstants.imageHeight)
                                .shadow(radius: DrawingConstants.imageShadow)
                                .padding(.horizontal)
                                .onTapGesture {
                                    showImageFullscreen = true
                                }
                            
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
            .sheet(isPresented: $showImageFullscreen) {
                NavigationStack {
                    ZStack {
                        WebImage(url: viewModel.person?.originalPersonImage)
                            .resizable()
                            .placeholder { ProgressView() }
                            .aspectRatio(contentMode: .fit)
                            .contextMenu {
                                #if os(iOS)
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
                                #endif

                            }
                        ConfirmationDialogView(showConfirmation: $showSaveConfirmation, message: "Image Saved.", image: "photo.fill")
                    }
                    .toolbar {
                        ToolbarItem {
                            Button("Done") { showImageFullscreen = false }
                        }
                    }
                }
#if os(macOS)
                    .frame(width: 500, height: 700, alignment: .center)
#endif
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
#if os(watchOS)
                    Rectangle().fill(.secondary)
#else
                    Rectangle().fill(.thickMaterial)
#endif
                    ProgressView()
                }
            }
        }
        .clipShape(Circle())
        .padding([.top, .bottom])
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
    static let imageShadow: CGFloat = 6
    static let imageWidth: CGFloat = 150
    static let imageHeight: CGFloat = 150
    static let padImageWidth: CGFloat = 250
    static let padImageHeight: CGFloat = 250
}
