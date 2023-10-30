//
//  HorizontalUpNextListView.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 19/03/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct HorizontalUpNextListView: View {
    @Binding var shouldReload: Bool
    @State private var selectedEpisode: UpNextEpisode?
    @StateObject private var settings = SettingsStore.shared
    @StateObject private var viewModel = UpNextViewModel()
    @FetchRequest(
        entity: WatchlistItem.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        predicate: NSCompoundPredicate(type: .and, subpredicates: [ NSPredicate(format: "displayOnUpNext == %d", true),
                                                                    NSPredicate(format: "isArchive == %d", false),
                                                                    NSPredicate(format: "watched == %d", false)])
    ) private var items: FetchedResults<WatchlistItem>
    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading) {
                if !viewModel.episodes.isEmpty {
#if !os(tvOS)
                    NavigationLink(value: viewModel.episodes) {
                        TitleView(title: "upNext", subtitle: "upNextSubtitle", showChevron: true)
                            .unredacted()
                    }
                    .disabled(!viewModel.isLoaded)
                    .buttonStyle(.plain)
#else
                    TitleView(title: "upNext", subtitle: "upNextSubtitle", showChevron: false)
                        .padding(.leading, 64)
#endif
                    
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack {
                                ForEach(viewModel.episodes) { item in
#if os(tvOS)
                                    UpNextCard(item: item, selectedEpisode: $selectedEpisode)
                                        .padding([.leading, .trailing], 4)
                                        .padding(.leading, item.id == viewModel.episodes.first?.id ? 64 : 0)
                                        .padding(.trailing, item.id == viewModel.episodes.last?.id ? 64 : 0)
                                        .padding(.top, 8)
                                        .padding(.bottom)
                                        .buttonStyle(.card)
                                        .environmentObject(viewModel)
#else
                                    if !settings.isCompactUI {
                                        upNextCard(item)
                                            .applyHoverEffect()
                                            .contextMenu {
                                                Button("showDetails") {
                                                    selectedEpisode = item
                                                }
                                                Button("upNextSkipThisEpisode") {
                                                    viewModel.skipEpisode(for: item)
                                                }
                                            }
                                            .padding([.leading, .trailing], 4)
                                            .padding(.leading, item.id == viewModel.episodes.first?.id ? 16 : 0)
                                            .padding(.trailing, item.id == viewModel.episodes.last?.id ? 16 : 0)
                                            .padding(.top, 8)
                                            .padding(.bottom)
                                            .onTapGesture {
                                                if SettingsStore.shared.markEpisodeWatchedOnTap {
                                                    Task {
														await viewModel.markAsWatched(item)
														guard let first = viewModel.episodes.first else { return }
														withAnimation {
															proxy.scrollTo(first.id, anchor: .topLeading)
														}
													}
                                                } else {
                                                    selectedEpisode = item
                                                }
                                            }
                                    } else {
                                        VStack {
                                            upNextCard(item)
                                            HStack {
                                                VStack(alignment: .leading) {
                                                    Text(item.showTitle)
                                                        .font(.caption)
                                                        .lineLimit(1)
                                                    Text(String(format: NSLocalizedString("S%d, E%d", comment: ""), item.episode.itemSeasonNumber, item.episode.itemEpisodeNumber))
                                                        .font(.caption)
                                                        .textCase(.uppercase)
                                                        .foregroundColor(.secondary)
                                                        .lineLimit(1)
                                                    Spacer()
                                                }
                                                Spacer()
                                            }
                                        }
                                        .frame(width: DrawingConstants.compactImageWidth)
                                        .contextMenu {
                                            Button("showDetails") {
                                                selectedEpisode = item
                                            }
                                            Button("upNextSkipThisEpisode") {
                                                viewModel.skipEpisode(for: item)
                                            }
                                        }
                                        .padding([.leading, .trailing], 4)
                                        .padding(.leading, item.id == viewModel.episodes.first?.id ? 16 : 0)
                                        .padding(.trailing, item.id == viewModel.episodes.last?.id ? 16 : 0)
                                        .padding(.top, 8)
                                        .padding(.bottom)
                                        .onTapGesture {
                                            if SettingsStore.shared.markEpisodeWatchedOnTap {
                                                Task {
													await viewModel.markAsWatched(item)
													guard let first = viewModel.episodes.first else { return }
													withAnimation {
														proxy.scrollTo(first.id, anchor: .topLeading)
													}
												}
                                            } else {
                                                selectedEpisode = item
                                            }
                                        }
                                    }
#endif
                                }
                            }
                            .onChange(of: viewModel.isWatched) {
                                guard let first = viewModel.episodes.first else { return }
                                if viewModel.isWatched {
                                    withAnimation {
                                        proxy.scrollTo(first.id, anchor: .topLeading)
                                    }
                                }
                            }
                        }
                        .onChange(of: shouldReload) { _, reload in
                            if reload {
                                if let firstItem = viewModel.episodes.first {
                                    withAnimation {
                                        proxy.scrollTo(firstItem.id, anchor: .topLeading)
                                    }
                                }
                                Task {
                                    await viewModel.reload(items)
                                    await MainActor.run {
                                        withAnimation(.easeInOut) {
                                            self.shouldReload = false
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .redacted(reason: viewModel.isLoaded ? [] : .placeholder)
            .navigationDestination(for: [UpNextEpisode].self) { _ in
                VerticalUpNextListView().environmentObject(viewModel)
            }
            .task(id: viewModel.isWatched) {
                if viewModel.isWatched {
                    await viewModel.handleWatched(selectedEpisode)
                    self.selectedEpisode = nil
                }
            }
            .task {
                await viewModel.load(items)
                await viewModel.checkForNewEpisodes(items)
            }
            .sheet(item: $selectedEpisode) { item in
                NavigationStack {
                    EpisodeDetailsView(episode: item.episode,
                                       season: item.episode.itemSeasonNumber,
                                       show: item.showID,
                                       showTitle: item.showTitle,
                                       isWatched: $viewModel.isWatched,
                                       isUpNext: true)
#if os(macOS) || os(iOS)
                    .toolbar { Button("Done") { self.selectedEpisode = nil } }
#endif
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
                        PersonDetailsView(name: person.name, id: person.id)
                    }
                }
                .appTheme()
                .appTint()
                .presentationDetents([.large])
#if os(tvOS)
                .ignoresSafeArea()
#endif
#if os(macOS)
                .frame(minWidth: 800, idealWidth: 800, minHeight: 600, idealHeight: 600, alignment: .center)
#endif
            }
        }
    }
    
    private func upNextCard(_ item: UpNextEpisode) -> some View {
        ZStack {
            WebImage(url: settings.preferCoverOnUpNext ? item.backupImage : item.episode.itemImageLarge ?? item.backupImage)
                .resizable()
                .placeholder {
                    ZStack {
                        Rectangle().fill(.gray.gradient)
                        Image(systemName: "popcorn.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.white.opacity(0.8))
                            .frame(width: 40, height: 40, alignment: .center)
							.unredacted()
                    }
                }
                .aspectRatio(contentMode: .fill)
                .frame(width: settings.isCompactUI ? DrawingConstants.compactImageWidth : DrawingConstants.imageWidth,
                       height: settings.isCompactUI ? DrawingConstants.compactImageHeight : DrawingConstants.imageHeight)
                .transition(.opacity)
            if !settings.isCompactUI {
                VStack(alignment: .leading) {
                    Spacer()
                    ZStack(alignment: .bottom) {
                        Color.black.opacity(0.4)
                            .frame(height: 50)
                            .mask {
                                LinearGradient(colors: [Color.black,
                                                        Color.black.opacity(0.924),
                                                        Color.black.opacity(0.707),
                                                        Color.black.opacity(0.383),
                                                        Color.black.opacity(0)],
                                               startPoint: .bottom,
                                               endPoint: .top)
                            }
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .frame(height: 70)
                            .mask {
                                VStack(spacing: 0) {
                                    LinearGradient(colors: [Color.black.opacity(0),
                                                            Color.black.opacity(0.383),
                                                            Color.black.opacity(0.707),
                                                            Color.black.opacity(0.924),
                                                            Color.black],
                                                   startPoint: .top,
                                                   endPoint: .bottom)
                                    .frame(height: 50)
                                    Rectangle()
                                }
                            }
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.showTitle)
                                    .font(.callout)
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                                Text(String(format: NSLocalizedString("S%d, E%d", comment: ""), item.episode.itemSeasonNumber, item.episode.itemEpisodeNumber))
                                    .font(.caption)
                                    .textCase(.uppercase)
                                    .foregroundColor(.white.opacity(0.8))
                                    .lineLimit(1)
                            }
                            Spacer()
                        }
                        .padding(.bottom, 8)
                        .padding(.leading)
                    }
                }
            }
        }
        .frame(width: settings.isCompactUI ? DrawingConstants.compactImageWidth : DrawingConstants.imageWidth,
               height: settings.isCompactUI ? DrawingConstants.compactImageHeight : DrawingConstants.imageHeight)
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
        .shadow(radius: 2.5)
        .accessibilityLabel("Episode: \(item.episode.itemEpisodeNumber), of the show: \(item.showTitle).")
        .accessibilityAddTraits(.isButton)
    }
    
}

#if os(tvOS)
private struct UpNextCard: View {
    let item: UpNextEpisode
    @FocusState var isFocused
    @Binding var selectedEpisode: UpNextEpisode?
    @StateObject private var settings = SettingsStore.shared
    @EnvironmentObject var viewModel: UpNextViewModel
    @State private var showConfirmation = false
    var body: some View {
        VStack {
            Button {
                showConfirmation.toggle()
                            } label: {
                WebImage(url: settings.preferCoverOnUpNext ? item.backupImage : item.episode.itemImageLarge ?? item.backupImage)
                    .resizable()
                    .placeholder {
                        ZStack {
                            Rectangle().fill(.gray.gradient)
                            Image(systemName: "sparkles.tv")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.white.opacity(0.8))
                                .frame(width: 40, height: 40, alignment: .center)
                                .padding()
                        }
                        .frame(width: DrawingConstants.imageWidth,
                               height: DrawingConstants.imageHeight)
                        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
                    }
                    .aspectRatio(contentMode: .fill)
                    .transition(.opacity)
                    .frame(width: DrawingConstants.imageWidth,
                           height: DrawingConstants.imageHeight)
                    .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius,
                                                style: .continuous))
                    .shadow(radius: DrawingConstants.imageShadow)
                    .applyHoverEffect()
            }
            .buttonStyle(.card)
            .focused($isFocused)
            HStack {
                Text(item.showTitle)
                    .font(.caption)
                    .lineLimit(2)
                    .accessibilityHidden(true)
                    .foregroundColor(isFocused ? .primary : .secondary)
                Spacer()
            }
            .frame(width: DrawingConstants.imageWidth)
            HStack {
                Text(String(format: NSLocalizedString("S%d, E%d", comment: ""), item.episode.itemSeasonNumber, item.episode.itemEpisodeNumber))
                    .font(.caption)
                    .textCase(.uppercase)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                Spacer()
            }
            Spacer()
        }
        .padding(.top)
        .alert("Confirm Watched Episode",
               isPresented: $showConfirmation) {
            Button("Confirm") {
                Task {
                    await viewModel.markAsWatched(item)
                }
            }
            Button("Cancel", role: .cancel) {
                showConfirmation = false
            }
        } message: {
            let localizedString = String.localizedStringWithFormat(NSLocalizedString("MARK_EPISODE_WATCHED", comment: ""), item.episode.itemEpisodeNumber, item.episode.itemSeasonNumber, item.showTitle)
            Text(localizedString)
        }
        .contextMenu {
            Button("Details") {
                selectedEpisode = item
            }
        }
    }
}
#endif

private struct DrawingConstants {
#if !os(tvOS)
    static let imageWidth: CGFloat = 280
    static let imageHeight: CGFloat = 160
#else
    static let imageWidth: CGFloat = 420
    static let imageHeight: CGFloat = 240
#endif
    static let compactImageWidth: CGFloat = 160
    static let compactImageHeight: CGFloat = 100
    static let imageRadius: CGFloat = 12
    static let titleLineLimit: Int = 1
    static let imageShadow: CGFloat = 2.5
}
