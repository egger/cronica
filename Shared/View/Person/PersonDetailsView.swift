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
    @State private var scope: WatchlistSearchScope = .noScope
    @State private var showImageFullscreen = false
    @State var popupType: ActionPopupItems?
    @State var showPopup = false
    init(title: String, id: Int) {
        _viewModel = StateObject(wrappedValue: PersonDetailsViewModel(id: id))
        self.name = title
        self.personUrl = URL(string: "https://www.themoviedb.org/\(MediaType.person.rawValue)/\(id)")!
    }
    var body: some View {
        VStack {
            ScrollView {
                
                ViewThatFits {
                    HStack {
                        imageProfile
                            .padding([.bottom, .horizontal])
#if !os(tvOS)
                        if let overview = viewModel.person?.biography {
                            OverviewBoxView(overview: overview, title: "", showAsPopover: true)
                                .frame(width: 500)
                                .padding([.bottom, .trailing])
                        }
#endif
                    }
#if os(macOS)
                    .padding(.top)
#endif
                    VStack {
                        imageProfile
                            .padding()
#if !os(tvOS)
                        if let overview = viewModel.person?.biography {
                            OverviewBoxView(overview: overview, title: "")
                                .padding([.horizontal, .bottom])
                        }
#endif
                    }
                }
                
                FilmographyListView(filmography: viewModel.credits,
                                    showPopup: $showPopup,
                                    popupType: $popupType)
                
                AttributionView()
                    .padding([.top, .bottom])
                    .unredacted()
            }
        }
        .actionPopup(isShowing: $showPopup, for: popupType)
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
            ToolbarItem(placement: .primaryAction) {
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
        .searchable(text: $viewModel.query, placement: UIDevice.isIPhone ? .navigationBarDrawer(displayMode: .always) : .toolbar)
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
        .navigationBarTitleDisplayMode(.large)
#endif
#if os(tvOS)
        .ignoresSafeArea(.all, edges: .horizontal)
#endif
        
    }
    
    private func load() {
        Task {
            await self.viewModel.load()
            if viewModel.isLoaded {
                await MainActor.run {
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
                        SearchItemView(item: item,
                                       showPopup: $showPopup,
                                       popupType: $popupType)
                    }
                case .movies:
                    ForEach(viewModel.credits.filter { ($0.itemTitle.localizedStandardContains(viewModel.query)) as Bool && $0.itemContentMedia == .movie }) { item in
                        SearchItemView(item: item,
                                       showPopup: $showPopup,
                                       popupType: $popupType)
                    }
                case .shows:
                    ForEach(viewModel.credits.filter { ($0.itemTitle.localizedStandardContains(viewModel.query)) as Bool && $0.itemContentMedia == .tvShow }) { item in
                        SearchItemView(item: item,
                                       showPopup: $showPopup,
                                       popupType: $popupType)
                    }
                }
            }
#else
            Table(viewModel.credits.filter { ($0.itemTitle.localizedStandardContains(viewModel.query)) as Bool }) {
                TableColumn("Title") { item in
                    SearchItemView(item: item, showConfirmation: $showConfirmationPopup)
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
                ZStack {
                    Circle().fill(.gray.gradient)
                    Image(systemName: "person.fill")
                        .resizable()
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 50, height: 50, alignment: .center)
                }
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
    static let imageShadow: CGFloat = 5
}
