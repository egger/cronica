//
//  Content.swift
//  Story
//
//  Created by Alexandre Madeira on 17/02/22.
//

import Foundation
import SwiftUI

struct Content: Identifiable, Decodable {
    let adult: Bool?
    let id: Int
    let title, name, overview: String?
    let posterPath, backdropPath, profilePath: String?
    let releaseDate, status: String?
    let runtime, numberOfEpisodes, numberOfSeasons: Int?
    let productionCompanies: [ProductionCompany]?
    let productionCountries: [ProductionCountry]?
    let seasons: [Season]?
    let genres: [Genre]?
    let credits: Credits?
    let recommendations: ContentResponse?
    let releaseDates: ReleaseDates?
    let mediaType: String?
    let videos: Videos?
    let nextEpisodeToAir, lastEpisodeToAir: Episode?
}
struct ProductionCompany: Decodable {
    let id: Int
    let logoPath: String?
    let name: String
}
struct ProductionCountry: Decodable {
    let name: String
}
struct Genre: Decodable, Identifiable {
    let id: Int
    let name: String?
}
struct ContentResponse: Identifiable, Decodable {
    let id: String?
    let results: [Content]
}
struct ContentSection: Identifiable {
    var id = UUID()
    let results: [Content]
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
        case .onTheAir: return .tvShow
        }
    }
}
