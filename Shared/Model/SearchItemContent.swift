//
//  SearchItem.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 10/08/23.
//

import Foundation

struct SearchItemContent: Identifiable, Codable, Hashable {
	let adult: Bool?
	let id: Int
	let title, name, overview, originalTitle: String?
	let posterPath, backdropPath, profilePath: String?
	let releaseDate, status, imdbId: String?
	let runtime, numberOfEpisodes, numberOfSeasons, voteCount: Int?
	let popularity, voteAverage: Double?
	let releaseDates: ReleaseDates?
	let mediaType: String?
	var nextEpisodeToAir, lastEpisodeToAir: Episode?
	let originalName, firstAirDate, homepage: String?
}

struct SearchItemContentResponse: Identifiable, Codable, Hashable {
	let id: String?
	let results: [SearchItemContent]
}
