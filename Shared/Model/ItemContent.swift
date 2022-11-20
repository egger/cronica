//
//  ItemContent.swift
//  Story
//
//  Created by Alexandre Madeira on 17/02/22.
//

import Foundation
import SwiftUI

/// A model that represents a movie or tv show.
///
/// it is also used for people only on multi search results.
struct ItemContent: Identifiable, Codable, Hashable, Sendable, Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(for: ItemContent.self, contentType: .itemContent)
        ProxyRepresentation(exporting: \.itemUrlProxy)
    }
    let adult: Bool?
    let id: Int
    let title, name, overview: String?
    let posterPath, backdropPath, profilePath: String?
    let releaseDate, status, imdbId: String?
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
    var videos: Videos?
    var nextEpisodeToAir, lastEpisodeToAir: Episode?
}
struct ProductionCompany: Codable, Hashable {
    let name: String
}
struct ProductionCountry: Codable, Hashable {
    let name: String
}
struct Genre: Codable, Identifiable, Hashable {
    let id: Int
    let name: String?
}
struct ItemContentResponse: Identifiable, Codable, Hashable {
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
}
