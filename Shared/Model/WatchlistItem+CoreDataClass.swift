//
//  WatchlistItem+CoreDataClass.swift
//  Story
//
//  Created by Alexandre Madeira on 11/03/23.
//
//

import Foundation
import CoreData

@objc(WatchlistItem)
public class WatchlistItem: NSManagedObject, Codable {
    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else {
            throw ContextError.NoContextFound
        }
        self.init(context: context)
        
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            contentID = try values.decode(String.self, forKey: .contentID)
            contentType = try values.decode(Int64.self, forKey: .contentType)
            date = try values.decode(Date.self, forKey: .date)
            favorite = try values.decode(Bool.self, forKey: .favorite)
            formattedDate = try values.decode(String.self, forKey: .formattedDate)
            genre = try values.decode(String.self, forKey: .genre)
            id = try values.decode(Int64.self, forKey: .id)
            image = try values.decode(URL.self, forKey: .image)
            imdbID = try values.decode(String.self, forKey: .imdbID)
            isArchive = try values.decode(Bool.self, forKey: .isArchive)
            isPin = try values.decode(Bool.self, forKey: .isPin)
            isWatching = try values.decode(Bool.self, forKey: .isWatching)
            largeCardImage = try values.decode(URL.self, forKey: .largeCardImage)
            largePosterImage = try values.decode(URL.self, forKey: .largePosterImage)
            lastEpisodeNumber = try values.decode(Int64.self, forKey: .lastEpisodeNumber)
            lastSelectedSeason = try values.decode(Int64.self, forKey: .lastSelectedSeason)
            lastValuesUpdated = try values.decode(Date.self, forKey: .lastValuesUpdated)
            lastWatchedEpisode = try values.decode(Int64.self, forKey: .lastWatchedEpisode)
            mediumPosterImage = try values.decode(URL.self, forKey: .mediumPosterImage)
            nextEpisodeNumber = try values.decode(Int64.self, forKey: .nextEpisodeNumber)
            nextSeasonNumber = try values.decode(Int64.self, forKey: .nextSeasonNumber)
            notify = try values.decode(Bool.self, forKey: .notify)
            originalTitle = try values.decode(String.self, forKey: .originalTitle)
            schedule = try values.decode(Int16.self, forKey: .schedule)
            shouldNotify = try values.decode(Bool.self, forKey: .shouldNotify)
            title = try values.decode(String.self, forKey: .title)
            upcomingSeason = try values.decode(Bool.self, forKey: .upcomingSeason)
            watched = try values.decode(Bool.self, forKey: .watched)
            watchedEpisodes = try values.decode(String.self, forKey: .watchedEpisodes)
            markedToDeleteOn = try values.decode(Date.self, forKey: .markedToDeleteOn)
            nextEpisodeCoverImage = try values.decode(URL.self, forKey: .nextEpisodeCoverImage)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(contentID, forKey: .contentID)
        try values.encode(contentType, forKey: .contentType)
        try values.encode(date, forKey: .date)
        try values.encode(favorite, forKey: .favorite)
        try values.encode(formattedDate, forKey: .formattedDate)
        try values.encode(genre, forKey: .genre)
        try values.encode(id, forKey: .id)
        try values.encode(image, forKey: .image)
        try values.encode(imdbID, forKey: .imdbID)
        try values.encode(isArchive, forKey: .isArchive)
        try values.encode(isPin, forKey: .isPin)
        try values.encode(isWatching, forKey: .isWatching)
        try values.encode(largeCardImage, forKey: .largeCardImage)
        try values.encode(largePosterImage, forKey: .largePosterImage)
        try values.encode(lastEpisodeNumber, forKey: .lastEpisodeNumber)
        try values.encode(lastSelectedSeason, forKey: .lastSelectedSeason)
        try values.encode(lastValuesUpdated, forKey: .lastValuesUpdated)
        try values.encode(lastWatchedEpisode, forKey: .lastWatchedEpisode)
        try values.encode(mediumPosterImage, forKey: .mediumPosterImage)
        try values.encode(nextEpisodeNumber, forKey: .nextEpisodeNumber)
        try values.encode(nextSeasonNumber, forKey: .nextSeasonNumber)
        try values.encode(notify, forKey: .notify)
        try values.encode(originalTitle, forKey: .originalTitle)
        try values.encode(schedule, forKey: .schedule)
        try values.encode(shouldNotify, forKey: .shouldNotify)
        try values.encode(title, forKey: .title)
        try values.encode(tmdbID, forKey: .tmdbID)
        try values.encode(upcomingSeason, forKey: .upcomingSeason)
        try values.encode(watched, forKey: .watched)
        try values.encode(watchedEpisodes, forKey: .watchedEpisodes)
        try values.encode(markedToDeleteOn, forKey: .markedToDeleteOn)
        try values.encode(nextEpisodeCoverImage, forKey: .nextEpisodeCoverImage)
    }
    
    enum CodingKeys: CodingKey {
        case contentID, contentType, date, favorite
        case formattedDate, genre, id, image
        case imdbID, isArchive, isPin, isWatching
        case largeCardImage, largePosterImage, lastEpisodeNumber
        case lastSelectedSeason, lastValuesUpdated
        case lastWatchedEpisode, mediumPosterImage
        case nextEpisodeNumber, nextSeasonNumber, notify
        case originalTitle, schedule, shouldNotify, title
        case tmdbID, upcomingSeason, watched, watchedEpisodes, markedToDeleteOn, nextEpisodeId
        case nextEpisodeCoverImage, list
    }
}

extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "managedObjectContext")!
}

enum ContextError: Error {
    case NoContextFound
}
