//
//  Filmography.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 28/04/22.
//

import Foundation

struct Filmography: Decodable, Identifiable {
    let id: Int
    let title, name, character, overview: String?
    let backdropPath, posterPath, releaseDate, mediaType: String?
}
