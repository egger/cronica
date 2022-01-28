//
//  Credits.swift
//  Story
//
//  Created by Alexandre Madeira on 21/01/22.
//

import Foundation

struct Credits: Decodable, Identifiable {
    var id = UUID()
    let cast, crew: [Cast]
}
