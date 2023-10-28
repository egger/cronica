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
	let type: MediaType
    @StateObject private var viewModel: ItemContentViewModel
    @State private var showCustomListSheet = false
    @State private var showMoreOptions = false
    @State private var isWatched = false
	@StateObject private var store = SettingsStore.shared
    init(id: Int, title: String, type: MediaType, image: URL?) {
        self.id = id
        self.title = title
		self.type = type
        self.image = image
        _viewModel = StateObject(wrappedValue: ItemContentViewModel(id: id, type: type))
    }
    var body: some View {
        VStack {
            ScrollView {
                HeroImage(url: image, title: title)
				
				if let quickInfo = viewModel.content?.itemQuickInfo {
					Text(type.title)
						.font(.caption)
						.multilineTextAlignment(.center)
						.padding(.horizontal)
						.foregroundColor(.secondary)
					Text(quickInfo)
						.font(.caption)
						.multilineTextAlignment(.center)
						.padding(.horizontal)
						.foregroundColor(.secondary)
				}
                
                DetailWatchlistButton(showCustomList: $showCustomListSheet)
                    .environmentObject(viewModel)
                    .padding()
                
                if let seasons = viewModel.content?.seasons {
                    NavigationLink("Seasons", value: seasons)
                        .padding([.horizontal, .bottom])
                }
                
                if viewModel.isInWatchlist {
                    customListButton.padding([.horizontal, .bottom])
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
                                    favoriteButton.padding(.bottom)
                                    pinButton.padding(.bottom)
                                    archiveButton.padding(.bottom)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
					shareButton
                }
                .padding([.bottom, .horizontal])
                
                AboutSectionView(about: viewModel.content?.itemOverview)
                
                AttributionView()
            }
        }
        .task { await viewModel.load() }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.large)
        .redacted(reason: viewModel.isLoading ? .placeholder : [])
        .sheet(isPresented: $showCustomListSheet) {
            if let contentID = viewModel.content?.itemContentID {
                NavigationStack {
                    ItemContentCustomListSelector(contentID: contentID,
                                                  showView: $showCustomListSheet,
                                                  title: title,
                                                  image: viewModel.content?.cardImageSmall)
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
            let keys = item.map { (key, _) in key }.first
            let value = item.map { (_, value) in value }.first
            if let keys, let value {
                EpisodeDetailsView(episode: value, season: keys, show: id, showTitle: title, isWatched: $isWatched)
            }
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
                  systemImage: viewModel.isWatched ? "rectangle.badge.checkmark.fill" : "rectangle.badge.checkmark")
        }
        .buttonStyle(.borderedProminent)
    }
    
    private var customListButton: some View {
        Button {
            showCustomListSheet.toggle()
        } label: {
            Text("addToCustomList")
        }
    }
    
    private var favoriteButton: some View {
        Button {
            viewModel.update(.favorite)
        } label: {
            Label(viewModel.isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                  systemImage: viewModel.isFavorite ? "heart.fill" : "heart")
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
	
	@ViewBuilder
	private var shareButton: some View {
		switch store.shareLinkPreference {
		case .tmdb: if let url = viewModel.content?.itemURL { ShareLink(item: url).labelStyle(.iconOnly) }
		case .cronica: if let cronicaUrl {
			ShareLink(item: cronicaUrl, message: Text(title))
				.labelStyle(.iconOnly)
		}
		}
	}
	
	private var cronicaUrl: URL? {
		if let item = viewModel.content {
			let encodedTitle = item.itemTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
			let posterPath = item.posterPath ?? String()
			let encodedPoster = posterPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
			return URL(string: "https://alexandremadeira.dev/cronica/details?id=\(item.itemContentID)&img=\(encodedPoster ?? String())&title=\(encodedTitle ?? String())")
		}
		return nil
	}
}

private struct DrawingConstants {
    static let imageRadius: CGFloat = 8
    static let lineLimit: Int = 1
}

//@available(watchOS 10, *)
//#Preview {
//    ItemContentView(id: ItemContent.example.id,
//                    title: ItemContent.example.itemTitle,
//                    type: ItemContent.example.itemContentMedia,
//                    image: ItemContent.example.cardImageMedium)
//}
