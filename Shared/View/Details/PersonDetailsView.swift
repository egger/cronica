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
    init(title: String, id: Int) {
        _viewModel = StateObject(wrappedValue: PersonDetailsViewModel(id: id))
        self.name = title
        self.personUrl = URL(string: "https://www.themoviedb.org/\(MediaType.person.rawValue)/\(id)")!
    }
    var body: some View {
        ZStack {
            VStack {
                ScrollView {
#if os(tvOS)
                    imageProfile.padding()
#else
                    ViewThatFits {
                        HStack {
                            imageProfile
                                .padding([.horizontal, .top])
                            
                            if viewModel.person?.hasBiography ?? false {
                                OverviewBoxView(overview: viewModel.person?.personBiography,
                                                title: name,
                                                type: .person)
                                .frame(width: 500)
                                .padding(.horizontal)
                            }
                        }
                        
                        VStack {
                            imageProfile
                                .padding()
                            
                            if viewModel.person?.hasBiography ?? false {
                                OverviewBoxView(overview: viewModel.person?.personBiography,
                                                title: name,
                                                type: .person)
                                .padding()
                            }
                        }
                    }
#endif
                    
                    FilmographyListView(filmography: viewModel.credits,
                                        showConfirmation: $showConfirmation)
                    
                    AttributionView()
                        .padding([.top, .bottom])
                        .unredacted()
                }
            }
            .task { load() }
            .redacted(reason: isLoading ? .placeholder : [])
#if os(iOS)
            .overlay(search)
            .searchScopes($scope) {
                ForEach(WatchlistSearchScope.allCases) { scope in
                    Text(scope.localizableTitle).tag(scope)
                }
            }
#endif
            .autocorrectionDisabled(true)
#if os(iOS) || os(macOS)
            .navigationTitle(name)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem {
                    ShareLink(item: personUrl)
                }
#elseif os(macOS)
                ToolbarItem(placement: .status) {
                    ShareLink(item: personUrl)
                }
#endif
            }
            .background {
                TranslucentBackground(image: viewModel.person?.personImage)
            }
            .alert("Error",
                   isPresented: $viewModel.showErrorAlert) {
                Button("Cancel") { }
                Button("Retry") {
                    Task { await viewModel.load() }
                }
            } message: {
                Text(viewModel.errorMessage)
            }
#if os(iOS)
            .searchable(text: $viewModel.query, placement: .automatic)
            .fullScreenCover(isPresented: $showImageFullscreen) {
                NavigationStack {
                    ZStack {
                        Rectangle().fill(.black).ignoresSafeArea(.all)
                        VStack {
                            WebImage(url: viewModel.person?.originalPersonImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding()
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                showImageFullscreen.toggle()
                            } label: {
                                Label("Back", systemImage: "chevron.left")
                                    .imageScale(.large)
                                    .foregroundColor(.black)
                                    .labelStyle(.iconOnly)
                            }
                            .tint(.white)
                            .buttonStyle(.borderedProminent)
                            .padding()
                        }
                    }
                }
            }
#endif
            ConfirmationDialogView(showConfirmation: $showConfirmation, message: "addedToWatchlist")
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
    
#if os(iOS)
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
                    SearchItemView(item: item, showConfirmation: $showConfirmation)
                        .buttonStyle(.plain)
                        .accessibilityHint(Text(item.itemTitle))
                }
            }
#endif
        }
    }
#endif
    
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
            .onTapGesture {
#if os(iOS)
                showImageFullscreen.toggle()
#endif
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
#if os(macOS) || os(tvOS)
    static let imageWidth: CGFloat = 250
    static let imageHeight: CGFloat = 250
#else
    static let imageWidth: CGFloat = UIDevice.isIPad ? 250 : 150
    static let imageHeight: CGFloat = UIDevice.isIPad ? 250 : 150
#endif
    static let imageShadow: CGFloat = 6
}
