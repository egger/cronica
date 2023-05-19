//
//  EpisodeDetailsView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 20/06/22.
//
import SwiftUI
import SDWebImageSwiftUI

struct EpisodeDetailsView: View {
    let episode: Episode
    let season: Int
    let show: Int
    private let persistence = PersistenceController.shared
    @Binding var isWatched: Bool
    @State private var isInWatchlist = false
    var isUpNext = false
    @State private var showItem: ItemContent?
    @State private var showOverview = false
#if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
#endif
    var body: some View {
        details
    }
    
#if os(tvOS)
    private var details: some View {
        ZStack {
            WebImage(url: episode.itemImageOriginal)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 1920, height: 1080)
            VStack {
                Spacer()
                ZStack {
                    Color.black.opacity(0.4)
                        .frame(height: 400)
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
                        .fill(.regularMaterial)
                        .frame(height: 600)
                        .mask {
                            VStack(spacing: 0) {
                                LinearGradient(colors: [Color.black.opacity(0),
                                                        Color.black.opacity(0.383),
                                                        Color.black.opacity(0.707),
                                                        Color.black.opacity(0.924),
                                                        Color.black],
                                               startPoint: .top,
                                               endPoint: .bottom)
                                .frame(height: 400)
                                Rectangle()
                            }
                        }
                }
            }
            .padding(.zero)
            .ignoresSafeArea()
            .frame(width: 1920, height: 1080)
            VStack(alignment: .leading) {
                Spacer()
                HStack {
                    Text(episode.itemTitle)
                        .lineLimit(1)
                        .font(.title3)
                    Spacer()
                }
                .padding(.horizontal)
                HStack(alignment: .bottom) {
                    VStack {
                        WatchEpisodeButton(episode: episode,
                                           season: season,
                                           show: show,
                                           isWatched: $isWatched)
                        .padding(.horizontal)
                    }
                    .padding()
                    Spacer()
                    VStack {
                        Button {
                            showOverview.toggle()
                        } label: {
                            VStack(alignment: .leading) {
                                Text(episode.itemOverview)
                                    .lineLimit(4)
                                    .font(.callout)
                                    .frame(maxWidth: 700)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .padding()
                    Spacer()
                    VStack(alignment: .leading) {
                        HStack {
                            InfoSegmentView(title: "Episode", info: "\(episode.itemEpisodeNumber)")
                            InfoSegmentView(title: "Season", info: "\(episode.itemSeasonNumber)")
                        }
                        InfoSegmentView(title: "Release", info: episode.itemDate)
                    }
                    .padding()
                    
                    Spacer()
                }
                .padding()
            }
            .padding()
        }
    }
#endif
    
#if os(iOS) || os(macOS)
    private var details: some View {
        VStack {
            ScrollView {
#if os(macOS)
                HeroImage(url: episode.itemImageLarge, title: episode.itemTitle)
                    .frame(width: DrawingConstants.padImageWidth,
                           height: DrawingConstants.padImageHeight)
                    .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
                    .shadow(radius: DrawingConstants.shadowRadius)
                    .padding(.top)
#else
                HeroImage(url: episode.itemImageLarge, title: episode.itemTitle)
                    .frame(width: (horizontalSizeClass == .regular) ? DrawingConstants.padImageWidth : DrawingConstants.imageWidth,
                           height: (horizontalSizeClass == .compact) ? DrawingConstants.imageHeight : DrawingConstants.padImageHeight)
                    .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
                    .shadow(radius: DrawingConstants.shadowRadius)
                
#endif
                
                if let info = episode.itemInfo {
                    CenterHorizontalView {
                        Text(info)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding([.top, .horizontal])
                }
                
                WatchEpisodeButton(episode: episode,
                                   season: season,
                                   show: show,
                                   isWatched: $isWatched)
                .tint(isWatched ? .red : .blue)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.horizontal)
                .keyboardShortcut("e", modifiers: [.control])
#if os(iOS)
                .buttonBorderShape(.capsule)
                .shadow(radius: 5)
#endif
                
#if os(iOS)
                if let showItem {
                    NavigationLink(value: showItem) {
                        Label("tvShowDetails", systemImage: "chevron.forward")
                            .foregroundColor(.white)
                            .frame(minWidth: 100)
                    }
                    .tint(.black)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding([.horizontal, .top])
                    .buttonBorderShape(.capsule)
                    .shadow(radius: 5)
                }
#endif
                
                OverviewBoxView(overview: episode.itemOverview,
                                title: episode.itemTitle,
                                type: .tvShow)
                .padding()
                
                CastListView(credits: episode.itemCast)
                
                AttributionView()
            }
            .navigationTitle(episode.itemTitle)
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .task { load() }
            .onAppear {
                if isUpNext {
                    Task {
                        showItem = try? await NetworkService.shared.fetchItem(id: show, type: .tvShow)
                    }
                }
            }
        }
        .background {
            TranslucentBackground(image: episode.itemImageLarge)
        }
        .navigationDestination(for: ItemContent.self) { item in
            ItemContentDetails(title: item.itemTitle,
                               id: item.id,
                               type: item.itemContentMedia)
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
#endif
    
    private func load() {
        isWatched = persistence.isEpisodeSaved(show: show, season: season, episode: episode.id)
    }
    
    private func checkIfItemIsSaved() {
        let contentId = "\(show)@\(MediaType.tvShow.toInt)"
        let isShowSaved = persistence.isItemSaved(id: contentId)
        isInWatchlist = isShowSaved
    }
}

private struct DrawingConstants {
    static let titleLineLimit: Int = 1
    static let shadowRadius: CGFloat = 12
    static let imageWidth: CGFloat = 360
    static let imageHeight: CGFloat = 210
    static let imageRadius: CGFloat = 12
    static let padImageWidth: CGFloat = 500
    static let padImageHeight: CGFloat = 300
    static let padImageRadius: CGFloat = 12
}
