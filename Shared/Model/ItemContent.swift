//
//  ItemContent.swift
//  Story
//
//  Created by Alexandre Madeira on 17/02/22.
//

import Foundation
import SwiftUI

/// Represents a movie, tv show model, it is also used for people only
/// on search.
struct ItemContent: Identifiable, Decodable, Hashable, Sendable {
    let adult: Bool?
    let id: Int
    let title, name, overview: String?
    let posterPath, backdropPath, profilePath: String?
    let releaseDate, status, imdbID: String?
    let runtime, numberOfEpisodes, numberOfSeasons, voteCount: Int?
    let popularity, voteAverage: Double?
    let productionCompanies: [ProductionCompany]?
    let productionCountries: [ProductionCountry]?
    let seasons: [Season]?
    let genres: [Genre]?
    let credits: Credits?
    let recommendations: ItemContentResponse?
    let releaseDates: ReleaseDates?
    let mediaType: String?
    let videos: Videos?
    let nextEpisodeToAir, lastEpisodeToAir: Episode?
}
struct ProductionCompany: Decodable, Hashable {
    let name: String
}
struct ProductionCountry: Decodable, Hashable {
    let name: String
}
struct Genre: Decodable, Identifiable, Hashable {
    let id: Int
    let name: String?
}
struct ReleaseDates: Decodable, Hashable {
    let results: [ReleaseDatesResult]
}
struct ReleaseDatesResult: Decodable, Hashable {
    let iso31661: String?
    let releaseDates: [ReleaseDate]?
}
struct ReleaseDate: Decodable, Hashable {
    let certification, iso6391, releaseDate: String?
    let type: Int?
}
struct ItemContentResponse: Identifiable, Decodable, Hashable {
    let id: String?
    let results: [ItemContent]
}
struct ItemContentSection: Identifiable, Sendable {
    var id = UUID()
    let results: [ItemContent]
    let endpoint: Endpoints
    var title: String {
        endpoint.title
    }
    var subtitle: String {
        endpoint.subtitle
    }
    var image: String {
        endpoint.image
    }
    var type: MediaType {
        switch endpoint {
        case .upcoming: return .movie
        case .nowPlaying: return .movie
        }
    }
}
