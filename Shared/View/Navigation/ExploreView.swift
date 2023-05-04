//
//  ExploreView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 30/04/22.
//

import SwiftUI

struct ExploreView: View {
    static let tag: Screens? = .explore
    @State private var showConfirmation = false
    @State private var onChanging = false
    @State private var showFilters = false
    @StateObject private var viewModel = ExploreViewModel()
    @StateObject private var settings = SettingsStore.shared
    var body: some View {
        ZStack {
            if !viewModel.isLoaded {  ProgressView().unredacted() }
            ScrollView {
                ScrollViewReader { proxy in
                    VStack {
#if os(tvOS)
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Explore")
                                    .font(.title3)
                                Text(viewModel.selectedMedia.title)
                                    .font(.callout)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            Spacer()
                            Button {
                                showFilters.toggle()
                            } label: {
                                Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                                    .labelStyle(.iconOnly)
                            }
                        }
                        .padding(.horizontal)
#endif
                        
                        switch settings.exploreDisplayType {
                        case .poster: posterStyle
                        case .card: cardStyle
                        }
                        
                        if !viewModel.items.isEmpty {
                            AttributionView()
                        }
                    }
                    .onChange(of: onChanging) { _ in
                        let first = viewModel.items[0]
                        withAnimation {
                            proxy.scrollTo(first.id, anchor: .topLeading)
                        }
                    }
                    .navigationDestination(for: ItemContent.self) { item in
#if os(macOS)
                        ItemContentDetailsView(id: item.id, title: item.itemTitle,
                                               type: item.itemContentMedia, handleToolbarOnPopup: true)
#else
                        ItemContentDetails(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
#endif
                    }
                    .navigationDestination(for: Person.self) { person in
#if os(tvOS)
#else
                        PersonDetailsView(title: person.name, id: person.id)
#endif
                    }
                    .navigationDestination(for: [String:[ItemContent]].self) { item in
                        let keys = item.map { (key, _) in key }
                        let value = item.map { (_, value) in value }
#if os(tvOS)
#else
                        ItemContentCollectionDetails(title: keys[0], items: value[0])
#endif
                    }
                    .navigationDestination(for: [Person].self) { items in
#if os(tvOS)
#else
                        DetailedPeopleList(items: items)
#endif
                    }
                    .navigationDestination(for: ProductionCompany.self) { item in
#if os(tvOS)
#else
                        CompanyDetails(company: item)
#endif
                    }
                    .navigationDestination(for: [ProductionCompany].self) { item in
#if os(tvOS)
#else
                        CompaniesListView(companies: item)
#endif
                    }
                }
            }
            ConfirmationDialogView(showConfirmation: $showConfirmation, message: "addedToWatchlist")
        }
        .sheet(isPresented: $showFilters, content: {
            NavigationStack {
                Form {
                    Section {
                        Picker(selection: $viewModel.selectedMedia) {
                            ForEach(MediaType.allCases) { type in
                                if type != .person {
                                    Text(type.title).tag(type)
                                }
                            }
                        } label: {
                            Text("mediaTypeDiscoverFilterTitle")
                        }
                        Picker(selection: $viewModel.selectedGenre) {
                            if viewModel.selectedMedia == .movie {
                                ForEach(viewModel.movies) { genre in
                                    Text(genre.name!).tag(genre)
                                }
                            } else {
                                ForEach(viewModel.shows) { genre in
                                    Text(genre.name!).tag(genre)
                                }
                            }
                        } label: {
                            Text("genreDiscoverFilterTitle")
                        }
#if os(iOS)
                        .pickerStyle(.navigationLink)
#endif
                    }
                    Section {
                        Toggle("hideAddedItemsDiscoverFilter", isOn: $viewModel.hideAddedItems)
                            .onChange(of: viewModel.hideAddedItems) { value in
                                if value {
                                    viewModel.hideItems()
                                } else {
                                    onChanging = true
                                    Task {
                                        await load()
                                    }
                                }
                            }
                    }
                }
                .toolbar {
                    ToolbarItem {
                        Button("Cancel") { showFilters = false }
                    }
                }
#if os(iOS)
                .navigationBarTitle("filterDiscoverTitle")
                .navigationBarTitleDisplayMode(.inline)
#elseif os(macOS)
                .formStyle(.grouped)
#endif
            }
            .presentationDetents([.medium, .large])
            .unredacted()
            .appTheme()
        })
#if os(iOS) || os(macOS)
        .navigationTitle("Explore")
#endif
        .task {
            await load()
        }
        .redacted(reason: !viewModel.isLoaded ? .placeholder : [] )
        .toolbar {
#if os(iOS) || os(macOS)
            ToolbarItem {
                HStack {
                    Button {
                        showFilters.toggle()
                    } label: {
                        Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                            .labelStyle(.iconOnly)
                            .foregroundColor(showFilters ? .secondary : nil)
                    }
                    .keyboardShortcut("f", modifiers: .command)
#if os(macOS)
                    styleOptions
#endif
                }
            }
#if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                styleOptions
            }
#endif
#endif
        }
        .onChange(of: viewModel.selectedMedia) { value in
            onChanging = true
            var genre: Genre?
            if value == .tvShow {
                genre = viewModel.shows[0]
            } else {
                genre = viewModel.movies[0]
            }
            if let genre {
                viewModel.selectedGenre = genre.id
            }
            Task {
                await load()
            }
        }
        .onChange(of: viewModel.selectedGenre) { _ in
            onChanging = true
            Task {
                await load()
            }
        }
    }
    
    @ViewBuilder
    private var cardStyle: some View {
        LazyVGrid(columns: DrawingConstants.columns, spacing: 20) {
            ForEach(viewModel.items) { item in
                CardFrame(item: item, showConfirmation: $showConfirmation)
                    .buttonStyle(.plain)
#if os(tvOS)
                    .padding(.bottom)
#endif
            }
            if viewModel.isLoaded && !viewModel.endPagination {
                CenterHorizontalView {
                    ProgressView()
                        .padding()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                viewModel.loadMoreItems()
                            }
                        }
                }
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private var posterStyle: some View {
        LazyVGrid(columns: settings.isCompactUI ? DrawingConstants.compactPosterColumns : DrawingConstants.posterColumns,
                  spacing: settings.isCompactUI ? DrawingConstants.compactSpacing : DrawingConstants.spacing) {
            ForEach(viewModel.items) { item in
                Poster(item: item, addedItemConfirmation: $showConfirmation)
                    .buttonStyle(.plain)
#if os(tvOS)
                    .padding(.bottom)
#endif
            }
            if viewModel.isLoaded && !viewModel.endPagination {
                CenterHorizontalView {
                    ProgressView()
                        .padding()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                viewModel.loadMoreItems()
                            }
                        }
                }
            }
        }
        .padding(.all, settings.isCompactUI ? 10 : nil)
    }
    
#if os(iOS) || os(macOS)
    private var styleOptions: some View {
        Menu {
            Picker(selection: $settings.exploreDisplayType) {
                ForEach(ExplorePreferredDisplayType.allCases) { item in
                    Text(item.title).tag(item)
                }
            } label: {
                Label("exploreDisplayTypePicker", systemImage: "rectangle.grid.2x2")
            }
        } label: {
            Label("exploreDisplayTypePicker", systemImage: "rectangle.grid.2x2")
                .labelStyle(.iconOnly)
        }
    }
#endif
    
    private func load() async {
        if onChanging {
            viewModel.restartFetch = true
            onChanging = false
            viewModel.loadMoreItems()
        } else {
            viewModel.loadMoreItems()
        }
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ExploreView()
        }
    }
}

private struct DrawingConstants {
#if os(macOS)
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
