//
//  Credits.swift
//  Story
//
//  Created by Alexandre Madeira on 21/01/22.
//

import Foundation

struct Credits: Decodable, Hashable {
    let cast, crew: [Person]
}
struct Person: Decodable, Identifiable, Hashable {
    let adult: Bool?
    let id: Int
    let name: String
    let job, character, biography, profilePath: String?
    let combinedCredits: Filmography?
}
struct Filmography: Decodable, Hashable {
    let cast, crew: [ItemContent]?
}
