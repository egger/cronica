//
//  Credits.swift
//  Story
//
//  Created by Alexandre Madeira on 21/01/22.
//

import Foundation

struct Credits: Decodable {
    let cast, crew: [Person]
}

struct Person: Decodable, Identifiable {
    let id: Int
    let name: String
    private let job, character, biography, birthday: String?
    private let profilePath: String?
    let combinedCredits: CombinedCredits?
}

struct CombinedCredits: Decodable {
    let cast, crew: [Filmography]?
}

struct Filmography: Decodable, Identifiable {
    let id: Int
    private let title, character, overview: String?
    private let backdropPath, posterPath, releaseDate, media_type: String?
}

extension Person {
    var mediumImage: URL? {
        if profilePath != nil {
            return Utilities.imageUrlBuilder(size: .medium, path: profilePath!)
        } else {
            return nil
        }
    }
    var personBiography: String {
        biography ?? ""
    }
    var role: String? {
        job ?? character
    }
}
extension Filmography {
    var itemTitle: String {
        title ?? NSLocalizedString("Title not found", comment: "Missing Title")
    }
    var image: URL? {
        if posterPath != nil {
            return Utilities.imageUrlBuilder(size: .medium, path: posterPath!)
        } else {
            return nil
        }
    }
    var media: MediaType {
        switch media_type {
        case "movie":
            return MediaType.movie
        case "tv":
            return MediaType.tvShow
        default:
            return MediaType.movie
        }
    }
}
