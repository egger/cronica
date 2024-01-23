//
//  ExploreView.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 30/04/22.
//

import SwiftUI
import CoreData

struct ExploreView: View {
    static let tag: Screens? = .explore
    @State private var showPopup = false
    @State private var onChanging = false
    @State private var showFilters = false
    @State private var popupType: ActionPopupItems?
    @StateObject private var settings = SettingsStore.shared
    
    private let service: NetworkService = NetworkService.shared
    @State private var items = [ItemContent]()
    @AppStorage("exploreViewSelectedGenre") private var selectedGenre: Int = 28
    @AppStorage("exploreViewSelectedMedia") private var selectedMedia: MediaType = .movie
    @State private var selectedSortBy: TMDBSortBy = .popularity
    @State private var selectedWatchProviders = [String]()
    @State private var isLoaded: Bool = false
    @State private var showErrorDialog: Bool = false
    @AppStorage("exploreViewHideAddedItems") private var hideAddedItems = false
    // MARK: Pagination Properties
    @State private var currentPage: Int = 0
    @State private var startPagination: Bool = false
    @State private var endPagination: Bool = false
    @State private var restartFetch: Bool = false
    
    // MARK: Genres array.
    private let movies: [Genre] = [
        Genre(id: 28, name: NSLocalizedString("Action", comment: "")),
        Genre(id: 12, name: NSLocalizedString("Adventure", comment: "")),
        Genre(id: 16, name: NSLocalizedString("Animation", comment: "")),
        Genre(id: 35, name: NSLocalizedString("Comedy", comment: "")),
        Genre(id: 80, name: NSLocalizedString("Crime", comment: "")),
        Genre(id: 99, name: NSLocalizedString("Documentary", comment: "")),
        Genre(id: 18, name: NSLocalizedString("Drama", comment: "")),
        Genre(id: 10751, name: NSLocalizedString("Family", comment: "")),
        Genre(id: 14, name: NSLocalizedString("Fantasy", comment: "")),
        Genre(id: 36, name: NSLocalizedString("History", comment: "")),
        Genre(id: 27, name: NSLocalizedString("Horror", comment: "")),
        Genre(id: 10402, name: NSLocalizedString("Music", comment: "")),
        Genre(id: 9648, name: NSLocalizedString("Mystery", comment: "")),
        Genre(id: 10749, name: NSLocalizedString("Romance", comment: "")),
        Genre(id: 878, name: NSLocalizedString("Science Fiction", comment: "")),
        Genre(id: 53, name: NSLocalizedString("Thriller", comment: "")),
        Genre(id: 10752, name: NSLocalizedString("War", comment: ""))
    ]
    private let shows: [Genre] = [
        Genre(id: 10759, name: NSLocalizedString("Action & Adventure", comment: "")),
        Genre(id: 16, name: NSLocalizedString("Animation", comment: "")),
        Genre(id: 35, name: NSLocalizedString("Comedy", comment: "")),
        Genre(id: 80, name: NSLocalizedString("Crime", comment: "")),
        Genre(id: 99, name: NSLocalizedString("Documentary", comment: "")),
        Genre(id: 18, name: NSLocalizedString("Drama", comment: "")),
        Genre(id: 10762, name: NSLocalizedString("Kids", comment: "")),
        Genre(id: 9648, name: NSLocalizedString("Mystery", comment: "")),
        Genre(id: 10765, name: NSLocalizedString("Sci-Fi & Fantasy", comment: ""))
    ]
    var body: some View {
        VStack {
            if settings.sectionStyleType == .list {
                listStyle
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
#if os(tvOS)
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Explore")
                                    .font(.title3)
                                Text(selectedMedia.title)
                                    .font(.callout)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            Spacer()
                            Menu {
                                hideItemsToggle
                                selectMediaPicker
                                selectGenrePicker
                                    .pickerStyle(.menu)
                            } label: {
                                Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                                    .labelStyle(.iconOnly)
                            }
                        }
                        .padding(.horizontal, 64)
#endif
                        
                        switch settings.sectionStyleType {
                        case .list: EmptyView()
                        case .poster: posterStyle
                        case .card: cardStyle
                        }
                    }
                    .onChange(of: onChanging) { _ in
                        guard let first = items.first else { return }
                        withAnimation {
                            proxy.scrollTo(first.id, anchor: .topLeading)
                        }
                    }
                }
            }
        }
        .overlay { if !isLoaded { CronicaLoadingPopupView() } }
        .actionPopup(isShowing: $showPopup, for: popupType)
        .task { await load() }
        .navigationDestination(for: ItemContent.self) { item in
            ItemContentDetails(title: item.itemTitle, id: item.id, type: item.itemContentMedia, handleToolbar: false)
#if os(tvOS)
                .ignoresSafeArea(.all, edges: .horizontal)
#endif
        }
        .navigationDestination(for: Person.self) { person in
            PersonDetailsView(name: person.name, id: person.id)
#if os(tvOS)
                .ignoresSafeArea(.all, edges: .horizontal)
#endif
        }
        .navigationDestination(for: [String:[ItemContent]].self) { item in
            let keys = item.map { (key, _) in key }
            let value = item.map { (_, value) in value }
#if os(tvOS)
#else
            ItemContentSectionDetails(title: keys[0], items: value[0])
#endif
        }
        .navigationDestination(for: [Person].self) { items in
#if os(tvOS)
#else
            DetailedPeopleList(items: items)
#endif
        }
        .navigationDestination(for: ProductionCompany.self) { item in
            CompanyDetails(company: item)
        }
        .navigationDestination(for: [ProductionCompany].self) { item in
            CompaniesListView(companies: item)
        }
#if !os(tvOS)
        .navigationTitle("Explore")
#elseif os(tvOS)
        .ignoresSafeArea(.all, edges: .horizontal)
#endif
        .redacted(reason: !isLoaded ? .placeholder : [] )
        .toolbar {
#if !os(tvOS)
            ToolbarItem {
                HStack {
                    Menu {
                        hideItemsToggle
                        Divider()
                        selectMediaPicker
                        Divider()
                        selectGenrePicker
                    } label: {
                        Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                            .labelStyle(.iconOnly)
                            .foregroundColor(showFilters ? .secondary : nil)
                    }
                }
            }
#if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                styleOptions
            }
#endif
#endif
        }
        .onChange(of: selectedMedia) { value in
            onChanging = true
            var genre: Genre?
            if value == .tvShow {
                genre = shows.first
            } else {
                genre = movies.first
            }
            if let genre {
                selectedGenre = genre.id
            }
            Task { await load() }
        }
        .onChange(of: selectedGenre) { _ in
            onChanging = true
            Task { await load() }
        }
    }
    
    private var selectMediaPicker: some View {
        Picker(selection: $selectedMedia) {
            ForEach(MediaType.allCases) { type in
                if type != .person {
                    Text(type.title).tag(type)
                }
            }
        } label: {
            Text("Media Type Filter")
        }
#if os(macOS)
        .pickerStyle(.inline)
#endif
    }
    
    private var selectGenrePicker: some View {
        Picker("Genres", selection: $selectedGenre) {
            if selectedMedia == .movie {
                ForEach(movies) { genre in
                    Text(genre.name!).tag(genre)
                }
            } else {
                ForEach(shows) { genre in
                    Text(genre.name!).tag(genre)
                }
            }
        }
#if os(iOS) || os(macOS)
        .pickerStyle(.inline)
#endif
    }
    
    private var hideItemsToggle: some View {
        Toggle("Hide Added Items", isOn: $hideAddedItems)
            .onChange(of: hideAddedItems) { value in
                if value {
                    hideItems()
                } else {
                    onChanging = true
                    Task {
                        await load()
                    }
                }
            }
    }
    
    private var listStyle: some View {
        Form {
            Section {
                List {
                    ForEach(items) { item in
                        ItemContentRowView(item: item, showPopup: $showPopup, popupType: $popupType)
                    }
                    if isLoaded && !endPagination {
                        CenterHorizontalView {
                            ProgressView("Loading")
                                .progressViewStyle(.circular)
                                .tint(settings.appTheme.color)
                                .padding(.horizontal)
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        loadMoreItems()
                                    }
                                }
                        }
                    }
                }
            }
        }
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
    
    private var cardStyle: some View {
        LazyVGrid(columns: DrawingConstants.columns, spacing: 20) {
            ForEach(items) { item in
                ItemContentCardView(item: item, showPopup: $showPopup, popupType: $popupType)
                    .buttonStyle(.plain)
#if os(tvOS)
                    .padding(.bottom)
#endif
            }
            if isLoaded && !endPagination {
                CenterHorizontalView {
                    ProgressView()
                        .padding()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                loadMoreItems()
                            }
                        }
                }
            }
        }
        .padding()
    }
    
    private var posterStyle: some View {
        LazyVGrid(columns: settings.isCompactUI ? DrawingConstants.compactPosterColumns : DrawingConstants.posterColumns,
                  spacing: settings.isCompactUI ? DrawingConstants.compactSpacing : DrawingConstants.spacing) {
            ForEach(items) { item in
                ItemContentPosterView(item: item, showPopup: $showPopup, popupType: $popupType)
                    .buttonStyle(.plain)
#if os(tvOS)
                    .padding(.bottom)
#endif
            }
            if isLoaded && !endPagination {
                CenterHorizontalView {
                    ProgressView()
                        .padding()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                loadMoreItems()
                            }
                        }
                }
            }
        }.padding(.all, settings.isCompactUI ? 10 : nil)
    }
    
#if os(iOS) || os(macOS)
    private var styleOptions: some View {
#if os(macOS)
        Picker(selection: $settings.sectionStyleType) {
            ForEach(SectionDetailsPreferredStyle.allCases) { item in
                Text(item.title).tag(item)
            }
        } label: {
            Label("Style Picker", systemImage: "circle.grid.2x2")
                .labelStyle(.iconOnly)
        }
#else
        Menu {
            Picker(selection: $settings.sectionStyleType) {
                ForEach(SectionDetailsPreferredStyle.allCases) { item in
                    Text(item.title).tag(item)
                }
            } label: {
                Label("Style Picker", systemImage: "circle.grid.2x2")
            }
        } label: {
            Label("Style Picker", systemImage: "circle.grid.2x2")
                .labelStyle(.iconOnly)
        }
#endif
    }
#endif
}

#Preview {
    NavigationStack {
        ExploreView()
    }
}

private struct DrawingConstants {
#if os(macOS) || os(visionOS)
    static let posterColumns = [GridItem(.adaptive(minimum: 160))]
    static let columns = [GridItem(.adaptive(minimum: 240))]
#elseif os(tvOS)
    static let posterColumns = [GridItem(.adaptive(minimum: 260))]
    static let columns = [GridItem(.adaptive(minimum: 440))]
#else
    static let posterColumns  = [GridItem(.adaptive(minimum: 160))]
    static let columns = [GridItem(.adaptive(minimum: UIDevice.isIPad ? 240 : 160))]
#endif
    static let compactPosterColumns = [GridItem(.adaptive(minimum: 80))]
    static let compactSpacing: CGFloat = 20
    static let spacing: CGFloat = 10
}

extension ExploreView {
    private func load() async {
        if onChanging {
            restartFetch = true
            onChanging = false
            loadMoreItems()
        } else {
            loadMoreItems()
        }
    }
    
    private func clearItems() {
        withAnimation {
            isLoaded = false
            items.removeAll()
        }
    }
    
    func hideItems() {
        let ids = fetchAllItemsIDs(selectedMedia)
        withAnimation {
            items.removeAll(where: { ids.contains($0.itemContentID)})
        }
    }
    
    func loadMoreItems(sortBy: TMDBSortBy = .popularity, reload: Bool = false) {
        if reload {
            withAnimation {
                items.removeAll()
                isLoaded = false
                currentPage = 0
                selectedSortBy = sortBy
            }
        }
        if restartFetch {
            currentPage = 0
            startPagination = true
            clearItems()
            restartFetch = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation {
                    self.isLoaded = true
                }
            }
        }
        currentPage += 1
        Task {
            await fetch()
        }
    }
    
    private func fetch() async {
        do {
            let result = try await service.fetchDiscover(type: selectedMedia,
                                                         page: currentPage,
                                                         genres: "\(selectedGenre)",
                                                         sort: selectedSortBy)
            if hideAddedItems {
                let ids = fetchAllItemsIDs(selectedMedia)
                items.append(contentsOf: result.filter { !ids.contains($0.itemContentID)})
            } else {
                for item in result {
                    if !items.contains(item) {
                        items.append(item)
                    }
                }
            }
            if currentPage == 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation {
                        self.isLoaded = true
                    }
                }
            }
            if result.isEmpty { endPagination = true }
            startPagination = false
        } catch {
            if Task.isCancelled { return }
            CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                  for: "ExploreView.fetch()")
            showErrorDialog.toggle()
        }
    }
    
    private func fetchAllItemsIDs(_ media: MediaType) -> [String] {
        let persistence = PersistenceController.shared
        let request: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()
        let typePredicate = NSPredicate(format: "contentType == %d", media.toInt)
        request.predicate = typePredicate
        do {
            let list = try persistence.container.viewContext.fetch(request)
            var ids = [String]()
            for item in list {
                ids.append(item.itemContentID)
            }
            return ids
        } catch {
            if Task.isCancelled { return [] }
            CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                  for: "ExploreView.fetchAllItemsIDs()")
            return []
        }
    }
}
