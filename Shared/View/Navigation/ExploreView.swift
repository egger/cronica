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
    @StateObject private var viewModel = DiscoverViewModel()
    var body: some View {
        ZStack {
            if !viewModel.isLoaded {  ProgressView().unredacted() }
            ScrollView {
                ScrollViewReader { proxy in
                    VStack {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: DrawingConstants.columns))], spacing: 20) {
                            ForEach(viewModel.items) { item in
                                CardFrame(item: item, showConfirmation: $showConfirmation)
                                    .buttonStyle(.plain)
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
                        PersonDetailsView(title: person.name, id: person.id)
                    }
                    .navigationDestination(for: [String:[ItemContent]].self) { item in
                        let keys = item.map { (key, _) in key }
                        let value = item.map { (_, value) in value }
                        ItemContentCollectionDetails(title: keys[0], items: value[0])
                    }
                    .navigationDestination(for: [Person].self) { items in
                        DetailedPeopleList(items: items)
                    }
                    .navigationDestination(for: ProductionCompany.self) { item in
                        CompanyDetails(company: item)
                    }
                    .navigationDestination(for: [ProductionCompany].self) { item in
                        CompaniesListView(companies: item)
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
        .navigationTitle("Explore")
        .task {
            await load()
        }
        .redacted(reason: !viewModel.isLoaded ? .placeholder : [] )
        .toolbar {
            ToolbarItem {
                Button {
                    showFilters.toggle()
                } label: {
                    Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                        .labelStyle(.iconOnly)
                        .foregroundColor(showFilters ? .secondary : nil)
                }
                .keyboardShortcut("f", modifiers: .command)
            }
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
    static let columns: CGFloat = 240
#else
    static let columns: CGFloat = UIDevice.isIPad ? 240 : 160
#endif
}
