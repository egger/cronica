//
//  Credits.swift
//  Story
//
//  Created by Alexandre Madeira on 21/01/22.
//

import Foundation

struct Credits: Decodable {
    let cast : [Cast]
    let crew : [Crew]
    enum CodingKeys: String, CodingKey {
        case cast = "cast"
        case crew = "crew"
    }
}
