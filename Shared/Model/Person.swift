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
    let job, character, biography, birthday: String?
    let profilePath: String?
    let combinedCredits: CombinedCredits?
}
struct CombinedCredits: Decodable {
    let cast, crew: [Filmography]?
}
struct Filmography: Decodable, Identifiable {
    let id: Int
    let title, character, overview: String?
    let backdropPath, posterPath, releaseDate, media_type: String?
}
