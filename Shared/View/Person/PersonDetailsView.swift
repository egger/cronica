//
//  PersonDetailsView.swift
//  Cronica
//
//  Created by Alexandre Madeira on 29/01/22.
//

import SwiftUI
import NukeUI

struct PersonDetailsView: View {
    let name: String
    let id: Int
    private let service: NetworkService = NetworkService.shared
    @State private var scope: WatchlistSearchScope = .noScope
    @State private var showImageFullscreen = false
    @State private var popupType: ActionPopupItems?
    @State private var showPopup = false
    @State private var isLoaded: Bool = false
    @State private var person: Person?
    @State private var credits = [ItemContent]()
    @State private var query: String = ""
    var body: some View {
        VStack {
            ScrollView {
                ViewThatFits {
                    HStack {
                        imageProfile
                            .padding([.bottom, .horizontal])
#if os(iOS) || os(macOS)
                        if let overview = person?.biography {
                            OverviewBoxView(
                                overview: overview,
                                title: "Biography",
                                type: .person,
                                showAsPopover: true
                            )
                            .frame(width: 500)
                            .padding([.bottom, .trailing])
                        }
#elseif os(tvOS)
                        Text(name)
                            .font(.title3)
                            .fontWeight(.semibold)
#endif
                    }
#if os(macOS)
                    .padding(.top)
#endif
                    VStack {
                        imageProfile
                            .padding()
#if os(iOS) || os(macOS)
                        if let overview = person?.biography {
                            OverviewBoxView(overview: overview, title: "", type: .person)
                                .padding([.horizontal, .bottom])
                        }
#endif
                    }
                }
                
                FilmographyListView(filmography: credits,
                                    showPopup: $showPopup,
                                    popupType: $popupType)
                .padding(.bottom)
            }
        }
        .actionPopup(isShowing: $showPopup, for: popupType)
        .task { await load() }
        .redacted(reason: isLoaded ? [] : .placeholder)
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
                shareButton
            }
#elseif os(macOS)
            ToolbarItem(placement: .primaryAction) {
                shareButton
            }
#endif
        }
        .background {
            if #available(iOS 17, *), #available(watchOS 10, *) {
                TranslucentBackground(image: person?.personImage)
            }
        }
#if os(iOS)
        .searchable(text: $query,
                    placement: UIDevice.isIPhone ? .navigationBarDrawer(displayMode: .always) : .toolbar)
        .fullScreenCover(isPresented: $showImageFullscreen) {
            NavigationStack {
                ZStack {
                    Rectangle().fill(.black).ignoresSafeArea(.all)
                    VStack {
                        LazyImage(url: person?.originalPersonImage) { state in
                            if let image = state.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding()
                            }
                        }
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
    
#if !os(tvOS)
    @ViewBuilder
    private var shareButton: some View {
        if let url = person?.itemURL {
            ShareLink(item: url, message: Text(name))
                .disabled(!isLoaded)
        }
    }
#endif
    
#if os(iOS)
    @ViewBuilder
    private var search: some View {
        if !query.isEmpty {
            List {
                switch scope {
                case .noScope:
                    ForEach(credits.filter { ($0.itemTitle.localizedStandardContains(query)) as Bool }) { item in
                        ItemContentSearchRowView(item: item,
                                                 showPopup: $showPopup,
                                                 popupType: $popupType)
                    }
                case .movies:
                    ForEach(credits.filter { ($0.itemTitle.localizedStandardContains(query)) as Bool && $0.itemContentMedia == .movie }) { item in
                        ItemContentSearchRowView(item: item,
                                                 showPopup: $showPopup,
                                                 popupType: $popupType)
                    }
                case .shows:
                    ForEach(credits.filter { ($0.itemTitle.localizedStandardContains(query)) as Bool && $0.itemContentMedia == .tvShow }) { item in
                        ItemContentSearchRowView(item: item,
                                                 showPopup: $showPopup,
                                                 popupType: $popupType)
                    }
                }
            }
        }
    }
#endif
    
    private var imageProfile: some View {
        PersonImageProfileView(person: person)
            .onTapGesture {
#if os(iOS)
                showImageFullscreen.toggle()
#endif
            }
    }
}

#Preview {
    PersonDetailsView(name: Person.previewCast.name,
                      id: Person.previewCast.id)
}

private struct DrawingConstants {
#if os(macOS) || os(tvOS)
    static let imageWidth: CGFloat = 250
    static let imageHeight: CGFloat = 250
#elseif os(iOS)
    static let imageWidth: CGFloat = UIDevice.isIPad ? 250 : 150
    static let imageHeight: CGFloat = UIDevice.isIPad ? 250 : 150
#else
    static let imageWidth: CGFloat = 100
    static let imageHeight: CGFloat = 100
#endif
    static let imageShadow: CGFloat = 5
}

private extension PersonDetailsView {
    func load() async {
        if Task.isCancelled { return }
        if person == nil {
            do {
                person = try await self.service.fetchPerson(id: self.id)
                if let person {
                    let cast = person.combinedCredits?.cast?.filter { $0.itemIsAdult == false } ?? []
                    let crew = person.combinedCredits?.crew?.filter { $0.itemIsAdult == false } ?? []
                    let combinedCredits = cast + crew
                    if !combinedCredits.isEmpty {
                        let combined = Array(Set(combinedCredits))
                        credits = combined.sorted(by: { $0.itemPopularity > $1.itemPopularity })
                    }
                }
                withAnimation {
                    isLoaded = true
                }
            } catch {
                if Task.isCancelled { return }
                person = nil
                let message = "Can't load the id \(id), with error message: \(error.localizedDescription)"
                CronicaTelemetry.shared.handleMessage(message, for: "PersonDetailsViewModel.load()")
            }
        }
    }
}

private struct PersonImageProfileView: View {
    let person: Person?
    var body: some View {
        LazyImage(url: person?.personImage) { state in
            if let image = state.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                ZStack {
                    Circle().fill(.gray.gradient)
                    Image(systemName: "person.fill")
                        .resizable()
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 50, height: 50, alignment: .center)
                        .unredacted()
                }
                .clipShape(Circle())
            }
        }
        .transition(.opacity)
        .clipShape(Circle())
        .frame(width: DrawingConstants.imageWidth, height: DrawingConstants.imageHeight)
        .shadow(radius: DrawingConstants.imageShadow)
        .accessibilityHidden(true)
    }
}
