//
//  Episode.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 28/04/22.
//

import Foundation

struct Episode: Identifiable, Decodable {
    let id, episodeNumber, seasonNumber: Int
    let crew, guestStars: [Person]?
    let name, overview, stillPath, airDate: String?
}
