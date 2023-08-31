//
//  VerticalUpNextListView.swift
//  Story
//
//  Created by Alexandre Madeira on 07/05/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct VerticalUpNextListView: View {
    @FetchRequest(
        entity: WatchlistItem.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        predicate: NSCompoundPredicate(type: .and, subpredicates: [ NSPredicate(format: "displayOnUpNext == %d", true),
                                                                    NSPredicate(format: "isArchive == %d", false),
                                                                    NSPredicate(format: "watched == %d", false)])
    ) private var items: FetchedResults<WatchlistItem>
    @EnvironmentObject var viewModel: UpNextViewModel
    @State private var selectedEpisode: UpNextEpisode?
    @State private var query = String()
    @State private var queryResult = [UpNextEpisode]()
	@StateObject private var settings = SettingsStore.shared
    var body: some View {
        VStack {
			if settings.upNextStyle == .card {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVGrid(columns: DrawingConstants.columns, spacing: 20) {
                            if !queryResult.isEmpty {
                                ForEach(queryResult) { item in
                                    VStack(alignment: .leading) {
                                        upNextCard(item: item)
                                            .contextMenu {
                                                if SettingsStore.shared.markEpisodeWatchedOnTap {
                                                    Button("showDetails") {
                                                        selectedEpisode = item
                                                    }
                                                }
                                            }
                                            .onTapGesture {
                                                if SettingsStore.shared.markEpisodeWatchedOnTap {
                                                    Task { await viewModel.markAsWatched(item) }
                                                } else {
                                                    selectedEpisode = item
                                                }
                                            }
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(item.showTitle)
                                                    .font(.caption)
                                                    .lineLimit(2)
                                                Text(String(format: NSLocalizedString("S%d, E%d", comment: ""), item.episode.itemSeasonNumber, item.episode.itemEpisodeNumber))
                                                    .font(.caption)
                                                    .textCase(.uppercase)
                                                    .foregroundColor(.secondary)
                                                    .lineLimit(1)
                                            }
                                            Spacer()
                                        }
                                        .frame(width: DrawingConstants.imageWidth)
                                        Spacer()
                                    }
                                }
                            } else if queryResult.isEmpty && !query.isEmpty {
                                CenterHorizontalView {
                                    Text("noResultsFound")
                                        .font(.headline)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                            } else {
                                ForEach(viewModel.episodes) { item in
                                    VStack(alignment: .leading) {
                                        upNextCard(item: item)
                                            .contextMenu {
                                                if SettingsStore.shared.markEpisodeWatchedOnTap {
                                                    Button("showDetails") {
                                                        selectedEpisode = item
                                                    }
                                                }
                                            }
                                            .onTapGesture {
                                                if SettingsStore.shared.markEpisodeWatchedOnTap {
                                                    Task { await viewModel.markAsWatched(item) }
                                                } else {
                                                    selectedEpisode = item
                                                }
                                            }
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(item.showTitle)
                                                    .font(.caption)
                                                    .lineLimit(2)
                                                Text(String(format: NSLocalizedString("S%d, E%d", comment: ""), item.episode.itemSeasonNumber, item.episode.itemEpisodeNumber))
                                                    .font(.caption)
                                                    .textCase(.uppercase)
                                                    .foregroundColor(.secondary)
                                                    .lineLimit(1)
                                            }
                                            Spacer()
                                        }
                                        .frame(width: DrawingConstants.imageWidth)
                                        Spacer()
                                    }
                                }
                            }
                        }
                        .onChange(of: viewModel.isWatched) { _ in
                            guard let first = viewModel.episodes.first else { return }
                            if viewModel.isWatched {
                                withAnimation {
                                    proxy.scrollTo(first.id, anchor: .topLeading)
                                }
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        Task { await viewModel.reload(items) }
                    }
                    .redacted(reason: viewModel.isLoaded ? [] : .placeholder)
                }
            } else {
                Form {
                    Section {
                        List {
                            if !queryResult.isEmpty {
                                ForEach(queryResult) { item in
                                    upNextRowItem(item)
                                        .onTapGesture {
                                            if SettingsStore.shared.markEpisodeWatchedOnTap {
                                                Task { await viewModel.markAsWatched(item) }
                                            } else {
                                                selectedEpisode = item
                                            }
                                        }
                                }
                            } else if queryResult.isEmpty && !query.isEmpty {
                                Text("noResultsFound")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            } else {
                                ForEach(viewModel.episodes) { item in
                                    upNextRowItem(item)
                                        .onTapGesture {
                                            if SettingsStore.shared.markEpisodeWatchedOnTap {
                                                Task { await viewModel.markAsWatched(item) }
                                            } else {
                                                selectedEpisode = item
                                            }
                                        }
                                }
                            }
                        }
                        .refreshable {
                            Task { await viewModel.reload(items) }
                        }
                        .redacted(reason: viewModel.isLoaded ? [] : .placeholder)
                    }
                }
#if os(macOS)
				.formStyle(.grouped)
#endif
            }
        }
#if os(iOS)
        .searchable(text: $query, placement: UIDevice.isIPhone ? .navigationBarDrawer(displayMode: .always) : .toolbar)
        .autocorrectionDisabled()
        .onChange(of: query) { _ in
            if query.isEmpty && !queryResult.isEmpty {
                withAnimation {
                    queryResult.removeAll()
                }
            } else {
                queryResult.removeAll()
                queryResult = viewModel.episodes.filter{ $0.showTitle.lowercased().contains(query.lowercased())}
            }
        }
#endif
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                styleOptions
            }
#endif
        }
        .sheet(item: $selectedEpisode) { item in
            NavigationStack {
                EpisodeDetailsView(episode: item.episode,
                                   season: item.episode.itemSeasonNumber,
                                   show: item.showID,
                                   showTitle: item.showTitle,
                                   isWatched: $viewModel.isWatched,
                                   isUpNext: true)
                .toolbar {
                    Button("Done") { self.selectedEpisode = nil }
                }
                .navigationDestination(for: ItemContent.self) { item in
                    ItemContentDetails(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
                }
                .navigationDestination(for: [String:[ItemContent]].self) { item in
                    let keys = item.map { (key, _) in key }
                    let value = item.map { (_, value) in value }
                    ItemContentSectionDetails(title: keys[0], items: value[0])
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
                .navigationDestination(for: Person.self) { person in
                    PersonDetailsView(title: person.name, id: person.id)
                }
            }
#if os(macOS)
            .frame(minWidth: 800, idealWidth: 800, minHeight: 600, idealHeight: 600, alignment: .center)
#elseif os(iOS)
            .appTheme()
            .appTint()
#endif
        }
        .task(id: viewModel.isWatched) {
            if viewModel.isWatched {
                await viewModel.handleWatched(selectedEpisode)
                self.selectedEpisode = nil
                if !query.isEmpty {
                    withAnimation {
                        queryResult.removeAll()
                        query = String()
                    }
                }
            }
        }
        .task {
            await viewModel.checkForNewEpisodes(items)
        }
        .navigationTitle("upNext")
#if os(iOS)
        .navigationBarTitleDisplayMode(.large)
#endif
    }
    
    private func upNextCard(item: UpNextEpisode) -> some View {
        WebImage(url: item.episode.itemImageMedium ?? item.backupImage)
            .resizable()
            .placeholder {
                ZStack {
                    Rectangle().fill(.gray.gradient)
                    Image(systemName: "sparkles.tv")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 40, height: 40, alignment: .center)
                }
            }
            .aspectRatio(contentMode: .fill)
            .frame(width: DrawingConstants.imageWidth,
                   height: DrawingConstants.imageHeight)
            .transition(.opacity)
            .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
            .shadow(radius: 2)
    }
    
    private func upNextRowItem(_ item: UpNextEpisode) -> some View {
        HStack {
            WebImage(url: item.episode.itemImageMedium ?? item.backupImage)
                .placeholder {
                    ZStack {
                        Rectangle().fill(.gray.gradient)
                        Image(systemName: "sparkles.tv")
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(width: 80, height: 50)
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .transition(.opacity)
                .frame(width: 80, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            VStack(alignment: .leading) {
                Text(item.showTitle)
                    .font(.callout)
                    .lineLimit(1)
                Text(String(format: NSLocalizedString("S%d, E%d", comment: ""), item.episode.itemSeasonNumber, item.episode.itemEpisodeNumber))
                    .font(.caption)
                    .textCase(.uppercase)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(.leading, 2)
            Spacer()
        }
    }
    
#if os(iOS) || os(macOS)
    private var styleOptions: some View {
        Menu {
			Picker(selection: $settings.upNextStyle) {
                ForEach(UpNextDetailsPreferredStyle.allCases) { item in
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
#endif
}

private struct DrawingConstants {
#if os(iOS)
    static let columns = [GridItem(.adaptive(minimum: 160))]
    static let imageWidth: CGFloat = 160
    static let imageHeight: CGFloat = 100
#else
    static let columns = [GridItem(.adaptive(minimum: 280))]
    static let imageWidth: CGFloat = 280
    static let imageHeight: CGFloat = 160
#endif
    static let imageRadius: CGFloat = 12
    static let titleLineLimit: Int = 1
    static let imageShadow: CGFloat = 2.5
}
