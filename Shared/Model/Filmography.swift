//
//  Filmography.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 28/04/22.
//

import Foundation

struct Filmography: Decodable, Identifiable, Hashable {
    let id: Int
    let adult: Bool?
    let popularity: Double?
    let title, name: String?
    let posterPath, mediaType: String?
}
