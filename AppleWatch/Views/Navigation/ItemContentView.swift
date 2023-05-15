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
    let url: URL
    let image: URL?
    @StateObject private var viewModel: ItemContentViewModel
    @State private var showCustomListSheet = false
    init(id: Int, title: String, type: MediaType, image: URL?) {
        self.id = id
        self.title = title
        self.image = image
        _viewModel = StateObject(wrappedValue: ItemContentViewModel(id: id, type: type))
        self.url = URL(string: "https://www.themoviedb.org/\(type.rawValue)/\(id)")!
    }
    var body: some View {
        VStack {
            ScrollView {
                HeroImage(url: image, title: title)
                    .clipShape(
                        RoundedRectangle(cornerRadius: DrawingConstants.imageRadius,
                                         style: .continuous)
                    )
                    .padding()
                
                DetailWatchlistButton()
                    .environmentObject(viewModel)
                    .padding()
                
                if let seasons = viewModel.content?.seasons {
                    NavigationLink("Seasons", value: seasons)
                        .padding([.horizontal, .bottom])
                }   
                
                watchButton
                    .padding([.horizontal, .bottom])
                
                ShareLink(item: url)
                    .padding([.horizontal, .bottom])
                
                if viewModel.isInWatchlist {
                    customListButton
                        .padding([.horizontal, .bottom])
                    favoriteButton
                        .padding([.horizontal, .bottom])
                    pinButton
                        .padding([.horizontal, .bottom])
                    archiveButton
                        .padding([.horizontal, .bottom])
                }
                
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
    }
    
    private var watchButton: some View {
        Button {
            viewModel.update(.watched)
        } label: {
            Label(viewModel.isWatched ? "Remove from Watched" : "Mark as Watched",
                  systemImage: viewModel.isWatched ? "minus.circle.fill" : "checkmark.circle.fill")
        }
        .buttonStyle(.bordered)
        .tint(viewModel.isWatched ? .yellow : .green)
        .controlSize(.large)
        .disabled(viewModel.isLoading)
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
        .disabled(!viewModel.isInWatchlist)
    }
    
    private var favoriteButton: some View {
        Button {
            viewModel.update(.favorite)
        } label: {
            Label(viewModel.isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                  systemImage: viewModel.isFavorite ? "heart.circle.fill" : "heart.circle")
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        .disabled(viewModel.isLoading)
    }
    
    private var archiveButton: some View {
        Button {
            viewModel.update(.archive)
        } label: {
            Label(viewModel.isArchive ? "Remove from Archive" : "Archive Item",
                  systemImage: viewModel.isArchive ? "archivebox.fill" : "archivebox")
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        .disabled(viewModel.isLoading)
    }
    
    private var pinButton: some View {
        Button {
            viewModel.update(.pin)
        } label: {
            Label(viewModel.isPin ? "Unpin Item" : "Pin Item",
                  systemImage: viewModel.isPin ? "pin.slash.fill" : "pin.fill")
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        .disabled(viewModel.isLoading)
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
