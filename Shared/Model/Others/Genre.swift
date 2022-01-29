//
//  Genre.swift
//  Story
//
//  Created by Alexandre Madeira on 21/01/22.
//

import Foundation

struct Genre: Decodable, Identifiable {
    let id: Int
    let name: String?
}
