//
//  ItemContentView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 03/08/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ItemContentView: View {
    let id: Int
    let title: String
    let image: URL?
    @StateObject private var viewModel: ItemContentViewModel
    @State private var showCustomListSheet = false
    @State private var showMoreOptions = false
    init(id: Int, title: String, type: MediaType, image: URL?) {
        self.id = id
        self.title = title
        self.image = image
        _viewModel = StateObject(wrappedValue: ItemContentViewModel(id: id, type: type))
    }
    var body: some View {
        VStack {
            ScrollView {
                HeroImage(url: image, title: title)
                    .clipShape(
                        RoundedRectangle(cornerRadius: DrawingConstants.imageRadius,
                                         style: .continuous)
                    )
                    .shadow(radius: 5)
                    .padding()
                
                DetailWatchlistButton()
                    .environmentObject(viewModel)
                    .padding()
                
                if let seasons = viewModel.content?.seasons {
                    NavigationLink("Seasons", value: seasons)
                        .padding([.horizontal, .bottom])
                }
                
                HStack {
                    if viewModel.isInWatchlist {
                        Button {
                            showMoreOptions.toggle()
                        } label: {
                            Label("More", systemImage: "ellipsis")
                                .labelStyle(.iconOnly)
                        }
                        .disabled(viewModel.isLoading)
                        .sheet(isPresented: $showMoreOptions) {
                            VStack {
                                ScrollView {
                                    watchButton.padding(.bottom)
                                    customListButton.padding(.bottom)
                                    favoriteButton.padding(.bottom)
                                    pinButton.padding(.bottom)
                                    archiveButton.padding(.bottom)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    if let url = viewModel.content?.itemURL {
                        ShareLink(item: url)
                            .labelStyle(.iconOnly)
                    }
                }
                .padding([.bottom, .horizontal])
                
                AboutSectionView(about: viewModel.content?.itemOverview)
                
                CompanionTextView()
                
                AttributionView()
            }
        }
        .task { await viewModel.load() }
        .navigationTitle(title)
        .redacted(reason: viewModel.isLoading ? .placeholder : [])
        .sheet(isPresented: $showCustomListSheet) {
            if let contentID = viewModel.content?.itemContentID {
                NavigationStack {
                    ItemContentCustomListSelector(contentID: contentID,
                                                  showView: $showCustomListSheet, title: title)
                }
            }
        }
        .navigationDestination(for: [Season].self) { seasons in
            SeasonListView(numberOfSeasons: seasons, id: id)
        }
        .navigationDestination(for: Season.self) { season in
            EpisodeListView(seasonNumber: season.seasonNumber, id: id)
        }
        .navigationDestination(for: [Int:Episode].self) { item in
            let keys = item.map { (key, _) in key }
            let value = item.map { (_, value) in value }
            EpisodeDetailsView(episode: value.first!, season: keys.first!, show: id)
        }
        .background {
            if #available(watchOS 10, *) {
                TranslucentBackground(image: image)
            }
        }
    }
    
    private var watchButton: some View {
        Button {
            viewModel.update(.watched)
        } label: {
            Label(viewModel.isWatched ? "Remove from Watched" : "Mark as Watched",
                  systemImage: viewModel.isWatched ? "minus.circle.fill" : "checkmark.circle.fill")
        }
        .buttonStyle(.borderedProminent)
    }
    
    private var customListButton: some View {
        Button {
            if viewModel.watchlistItem == nil {
                viewModel.fetchSavedItem()
            }
            showCustomListSheet.toggle()
        } label: {
            Label("addToCustomList", systemImage: "rectangle.on.rectangle.angled")
        }
        .buttonStyle(.borderedProminent)
    }
    
    private var favoriteButton: some View {
        Button {
            viewModel.update(.favorite)
        } label: {
            Label(viewModel.isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                  systemImage: viewModel.isFavorite ? "heart.circle.fill" : "heart.circle")
        }
        .buttonStyle(.borderedProminent)
    }
    
    private var archiveButton: some View {
        Button {
            viewModel.update(.archive)
        } label: {
            Label(viewModel.isArchive ? "Remove from Archive" : "Archive Item",
                  systemImage: viewModel.isArchive ? "archivebox.fill" : "archivebox")
        }
        .buttonStyle(.borderedProminent)
    }
    
    private var pinButton: some View {
        Button {
            viewModel.update(.pin)
        } label: {
            Label(viewModel.isPin ? "Unpin Item" : "Pin Item",
                  systemImage: viewModel.isPin ? "pin.slash.fill" : "pin.fill")
        }
        .buttonStyle(.borderedProminent)
    }
}

struct ItemContentView_Previews: PreviewProvider {
    static var previews: some View {
        ItemContentView(id: ItemContent.example.id,
                        title: ItemContent.example.itemTitle,
                        type: ItemContent.example.itemContentMedia,
                        image: ItemContent.example.cardImageMedium)
    }
}

private struct DrawingConstants {
    static let imageRadius: CGFloat = 8
    static let lineLimit: Int = 1
}

private struct AddToCustomList {
    @Binding var showView: Bool
    @Binding var item: WatchlistItem?
    var body: some View {
        NavigationStack {
            Form {
                
            }
        }
    }
}
