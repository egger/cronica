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
            id = try values.decode(Int64.self, forKey: .id)
            title = try values.decode(String.self, forKey: .title)
            contentID = try values.decode(String.self, forKey: .contentID)
            image = try values.decode(URL?.self, forKey: .image)
            watchedEpisodes = try values.decode(String.self, forKey: .watchedEpisodes)
            watched = try values.decode(Bool.self, forKey: .watched)
            favorite = try values.decode(Bool.self, forKey: .favorite)
            contentType = try values.decode(Int64.self, forKey: .contentType)
            schedule = try values.decode(Int16.self, forKey: .schedule)
            largeCardImage = try values.decode(URL?.self, forKey: .largeCardImage)
            largePosterImage = try values.decode(URL?.self, forKey: .largePosterImage)
            mediumPosterImage = try values.decode(URL?.self, forKey: .mediumPosterImage)
            shouldNotify = try values.decode(Bool.self, forKey: .shouldNotify)
            isArchive = try values.decode(Bool.self, forKey: .isArchive)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(title, forKey: .title)
        try values.encode(contentID, forKey: .contentID)
        try values.encode(id, forKey: .id)
        try values.encode(image, forKey: .image)
        try values.encode(watchedEpisodes, forKey: .watchedEpisodes)
        try values.encode(watched, forKey: .watched)
        try values.encode(favorite, forKey: .favorite)
        try values.encode(contentType, forKey: .contentType)
        try values.encode(schedule, forKey: .schedule)
        try values.encode(largeCardImage, forKey: .largeCardImage)
        try values.encode(largePosterImage, forKey: .largePosterImage)
        try values.encode(mediumPosterImage, forKey: .mediumPosterImage)
        try values.encode(shouldNotify, forKey: .shouldNotify)
        try values.encode(isArchive, forKey: .isArchive)
    }
    
    enum CodingKeys: CodingKey {
        case title, contentID, id, image, watchedEpisodes, watched, favorite, contentType, schedule, largeCardImage,
             largePosterImage, mediumPosterImage, shouldNotify, isArchive
    }
}

extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "managedObjectContext")!
}

enum ContextError: Error {
    case NoContextFound
}
