//
//  Person.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 26/08/22.
//

import Foundation

struct Person: Codable, Identifiable {
    let id: Int
    let name: String
    let job, character, biography, profilePath: String?
}
