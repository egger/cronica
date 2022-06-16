//
//  ItemContent.swift
//  Story
//
//  Created by Alexandre Madeira on 17/02/22.
//

import Foundation
import SwiftUI

struct ItemContent: Identifiable, Decodable {
    let adult: Bool?
    let id: Int
    let title, name, overview: String?
    let posterPath, backdropPath, profilePath: String?
    let releaseDate, status: String?
    let runtime, numberOfEpisodes, numberOfSeasons: Int?
    let popularity: Double?
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
struct ProductionCompany: Decodable {
    let name: String
}
struct ProductionCountry: Decodable {
    let name: String
}
struct Genre: Decodable, Identifiable {
    let id: Int
    let name: String?
}
struct ReleaseDates: Decodable {
    let results: [ReleaseDatesResult]
}
struct ReleaseDatesResult: Decodable {
    let iso31661: String?
    let releaseDates: [ReleaseDate]?
}
struct ReleaseDate: Decodable {
    let certification, iso6391, releaseDate: String?
    let type: Int?
}
struct ItemContentResponse: Identifiable, Decodable {
    let id: String?
    let results: [ItemContent]
}
struct ItemContentSection: Identifiable {
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
