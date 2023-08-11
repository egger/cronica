//
//  ExploreView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 30/04/22.
//

import SwiftUI

struct ExploreView: View {
    static let tag: Screens? = .explore
    @State private var showPopup = false
    @State private var onChanging = false
    @State private var showFilters = false
    @State private var popupType: ActionPopupItems?
    @StateObject private var viewModel = ExploreViewModel()
    @StateObject private var settings = SettingsStore.shared
	@State private var sortBy: TMDBSortBy = .popularity
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
                        .padding(.horizontal, 64)
#endif
                        
                        switch settings.sectionStyleType {
                        case .list: EmptyView()
                        case .poster: posterStyle
                        case .card: cardStyle
                        }
                    }
                    .onChange(of: onChanging) { _ in
                        guard let first = viewModel.items.first else { return }
                        withAnimation {
                            proxy.scrollTo(first.id, anchor: .topLeading)
                        }
                    }
                }
            }
        }
        .overlay { if !viewModel.isLoaded {  ProgressView().unredacted() } }
        .actionPopup(isShowing: $showPopup, for: popupType)
        .task {
            await load()
        }
        .navigationDestination(for: ItemContent.self) { item in
            ItemContentDetails(title: item.itemTitle, id: item.id, type: item.itemContentMedia, handleToolbar: false)
#if os(tvOS)
                .ignoresSafeArea(.all, edges: .horizontal)
#endif
        }
        .navigationDestination(for: Person.self) { person in
            PersonDetailsView(title: person.name, id: person.id)
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
#if os(tvOS)
#else
            CompaniesListView(companies: item)
#endif
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
#if os(iOS)
                                .foregroundColor(.secondary)
#endif
                        }
#if os(iOS)
                        .pickerStyle(.segmented)
#endif
                    } header: {
                        Text("mediaTypeDiscoverFilterTitle")
                    }
                    Section {
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
                            EmptyView()
                            
                        }
#if os(iOS)
                        .pickerStyle(.inline)
#endif
                    } header: {
                        Text("genreDiscoverFilterTitle")
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
            .presentationDetents([.large])
            .unredacted()
            .appTheme()
        })
#if os(iOS) || os(macOS)
        .navigationTitle("Explore")
#elseif os(tvOS)
        .ignoresSafeArea(.all, edges: .horizontal)
#endif
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
					//sortButton
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
                genre = viewModel.shows.first
            } else {
                genre = viewModel.movies.first
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
		.onChange(of: sortBy) { newSortByValue in
			viewModel.loadMoreItems(sortBy: newSortByValue, reload: true)
		}
    }
    
    private var listStyle: some View {
        Form {
            Section {
                List {
                    ForEach(viewModel.items) { item in
                        ItemContentRowView(item: item, showPopup: $showPopup, popupType: $popupType)
                    }
                    if viewModel.isLoaded && !viewModel.endPagination {
                        CenterHorizontalView {
                            ProgressView("Loading")
                                .progressViewStyle(.circular)
                                .tint(settings.appTheme.color)
                                .padding(.horizontal)
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        viewModel.loadMoreItems()
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
            ForEach(viewModel.items) { item in
                ItemContentCardView(item: item, showPopup: $showPopup, popupType: $popupType)
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
    
    private var posterStyle: some View {
        LazyVGrid(columns: settings.isCompactUI ? DrawingConstants.compactPosterColumns : DrawingConstants.posterColumns,
                  spacing: settings.isCompactUI ? DrawingConstants.compactSpacing : DrawingConstants.spacing) {
            ForEach(viewModel.items) { item in
                ItemContentPosterView(item: item, showPopup: $showPopup, popupType: $popupType)
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
        }.padding(.all, settings.isCompactUI ? 10 : nil)
    }
    
#if os(iOS) || os(macOS)
    private var styleOptions: some View {
        Menu {
            Picker(selection: $settings.sectionStyleType) {
                ForEach(SectionDetailsPreferredStyle.allCases) { item in
                    Text(item.title).tag(item)
                }
            } label: {
                Label("sectionStyleTypePicker", systemImage: "circle.grid.2x2")
            }
        } label: {
            Label("sectionStyleTypePicker", systemImage: "circle.grid.2x2")
                .labelStyle(.iconOnly)
        }
    }
	
	private var sortButton: some View {
		Menu {
			Picker(selection: $sortBy) {
				ForEach(TMDBSortBy.allCases) { item in
					Text(item.localizedString).tag(item)
				}
			} label: {
				Label("Sort By", systemImage: "arrow.up.arrow.down.circle")
			}
		} label: {
			Label("Sort By", systemImage: "arrow.up.arrow.down.circle")
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
