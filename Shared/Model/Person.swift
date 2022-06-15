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
    let adult: Bool?
    let id: Int
    let name: String
    let job, character, biography, profilePath: String?
    let combinedCredits: Filmography?
}
struct Filmography: Decodable {
    let cast, crew: [ItemContent]?
}
