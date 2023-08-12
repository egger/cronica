//
//  WatchlistItem-CoreDataHelpers.swift
//  Story
//
//  Created by Alexandre Madeira on 15/02/22.
//

import Foundation
import CoreData

extension WatchlistItem {
    var itemTitle: String {
        title ?? NSLocalizedString("No title available", comment: "")
    }
    var itemOriginalTitle: String {
        originalTitle ?? NSLocalizedString("No title available", comment: "")
    }
    var itemLastUpdateDate: Date {
        lastValuesUpdated ?? Date.distantPast
    }
    var itemReleaseDate: Date {
        itemDate ?? Date.distantPast
    }
    var itemId: Int {
        Int(id)
    }
    var itemImage: URL? {
        guard let largeCardImage else { return image }
        return largeCardImage
    }
    var itemMedia: MediaType {
        switch contentType {
        case 0: return .movie
        case 1: return .tvShow
        case 2: return .person
        default: return .movie
        }
    }
    var itemSchedule: ItemSchedule {
        switch schedule {
        case 0: return .soon
        case 1: return .released
        case 2: return .production
        case 3: return .cancelled
        case 5: return .renewed
        case 6: return .ended
        default: return .unknown
        }
    }
    var itemLink: URL {
        return URL(string: "https://www.themoviedb.org/\(itemMedia.rawValue)/\(itemId)")!
    }
    var itemGlanceInfo: String? {
#if !os(watchOS)
        switch itemMedia {
        case .tvShow:
            if upcomingSeason {
                guard let formattedDate else {
                    return NSLocalizedString("Season \(nextSeasonNumber)", comment: "")
                }
                let season = NSLocalizedString("Season", comment: "")
                return "\(season) \(nextSeasonNumber) • \(formattedDate)"
            }
        default:
            guard let formattedDate else { return nil }
            return formattedDate
        }
        return nil
#else
        guard let date else { return nil }
        return date.toShortString()
#endif
    }
    var isWatched: Bool {
        return watched
    }
    var isFavorite: Bool {
        return favorite
    }
    var isMovie: Bool {
        if itemMedia == .movie { return true }
        return false
    }
    var isTvShow: Bool {
        if itemMedia == .tvShow { return true }
        return false
    }
    var isReleased: Bool {
        if isArchive { return false }
        if itemMedia == .movie {
            return isReleasedMovie
        } else {
            return isReleasedTvShow
        }
    }
    var isUpcoming: Bool {
        if isArchive { return false }
        if itemMedia == .movie {
            return isUpcomingMovie
        } else {
            return isUpcomingTvShow
        }
    }
	var isReleasedMovie: Bool {
        if itemMedia == .movie {
            if itemSchedule == .released && !notify && !isWatched {
                return true
            }
        }
        return false
    }
    private var isReleasedTvShow: Bool {
        if itemMedia == .tvShow {
            if isWatched { return false }
            if itemSchedule == .ended { return true }
			if itemSchedule == .released && !isWatched { return true }
			if itemSchedule == .cancelled && !isWatched { return true }
			if let firstAirDate {
				if firstAirDate < Date() && !isWatched { return true }
			}
            if itemSchedule == .renewed && nextSeasonNumber == 1 && nextEpisodeNumber > 1 { return true }
            if itemSchedule == .renewed && nextSeasonNumber != 1 { return true }
        }
        return false
    }
    private var isUpcomingMovie: Bool {
        if itemMedia == .movie {
            if itemSchedule == .soon && notify { return true }
            if itemSchedule == .soon { return true }
        }
        return false
    }
    private var isUpcomingTvShow: Bool {
        if itemMedia == .tvShow {
            if itemSchedule == .soon && upcomingSeason && notify { return true }
            if itemSchedule == .soon && upcomingSeason { return true }
            if itemSchedule == .soon && nextSeasonNumber == 1 { return true }
            if itemSchedule == .renewed && notify && date != nil && upcomingSeason { return true }
            if itemSchedule == .renewed && nextSeasonNumber == 1 && nextEpisodeNumber == 1 { return true }
        }
        return false
    }
    var isInProduction: Bool {
        if isArchive { return false }
        if nextSeasonNumber == 1 && itemSchedule == .soon && !isWatched && !notify { return true }
        if itemSchedule == .soon && date == nil  { return true }
        if itemSchedule == .production && nextSeasonNumber == 1 { return true }
        if itemSchedule == .production { return true }
        return false
    }
    var isCurrentlyWatching: Bool {
        if isMovie { return false }
        if isTvShow && isWatched { return false }
        if isArchive || isWatched { return false }
		if isTvShow && isArchive { return false }
		if isTvShow && !(watchedEpisodes?.isEmpty ?? false) { return true }
        return isWatching
    }
    var itemContentID: String {
        return "\(itemId)@\(itemMedia.toInt)"
    }
    var itemDate: Date? {
		if let firstAirDate {
			return firstAirDate
		}
		if let movieReleaseDate {
			return movieReleaseDate
		}
        guard let date else { return nil }
        return date
    }
    var itemSortDate: Date {
        itemDate ?? Date.distantPast
    }
    var canShowOnUpcoming: Bool {
        if isArchive { return false }
        if itemMedia == .tvShow {
            if image != nil && isUpcomingTvShow { return true }
            return false
        } else {
            if image != nil && isUpcomingMovie { return true }
            return false
        }
    }
    var itemHasNote: Bool {
        if userNotes.isEmpty { return false }
        return true
    }
    static var example: WatchlistItem {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        let item = WatchlistItem(context: viewContext)
        item.title = ItemContent.example.itemTitle
        item.id = Int64(ItemContent.example.id)
        item.image = ItemContent.example.cardImageMedium
        item.contentType = 0
        item.notify = false
        return item
    }
    
    var itemLists: Set<CustomList> {
        return list as? Set<CustomList> ?? []
    }
    var listsArray: [CustomList] {
        let set = list as? Set<CustomList> ?? []
        return set.sorted {
            $0.itemTitle < $1.itemTitle
        }
    }
    var hasItemBeenAddedToList: Bool {
        if itemLists.isEmpty { return false }
        return true
    }
    var itemNextUpNextSeason: Int64 {
        if seasonNumberUpNext == 0 { return 1 }
        return seasonNumberUpNext
    }
    var itemNextUpNextEpisode: Int64 {
        if nextEpisodeNumberUpNext == 0 {
            return 1
        } else {
            return nextEpisodeNumberUpNext
        }
    }
	var backCompatibleSmallCardImage: URL? {
		if backdropPath != nil { return itemCardImageSmall }
		return image
	}
	var backCompatibleCardImage: URL? {
		if backdropPath != nil { return itemCardImageMedium }
		return image
	}
	var backCompatiblePosterImage: URL? {
		if posterPath != nil { return itemPosterImageMedium }
		return mediumPosterImage
	}
	var itemPosterImageMedium: URL? {
		return NetworkService.urlBuilder(size: .medium, path: posterPath)
	}
	var itemPosterImageLarge: URL? {
		return NetworkService.urlBuilder(size: .w780, path: posterPath)
	}
	var itemCardImageSmall: URL? {
		return NetworkService.urlBuilder(size: .small, path: backdropPath)
	}
	var itemCardImageMedium: URL? {
#if os(tvOS) || os(macOS)
		return NetworkService.urlBuilder(size: .w780, path: backdropPath)
#else
		return NetworkService.urlBuilder(size: .medium, path: backdropPath)
#endif
	}
	var itemCardImageLarge: URL? {
		return NetworkService.urlBuilder(size: .large, path: backdropPath)
	}
	var itemCardImageOriginal: URL? {
		return NetworkService.urlBuilder(size: .original, path: backdropPath)
	}
}

