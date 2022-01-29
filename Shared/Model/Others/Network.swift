//
//  Network.swift
//  Story
//
//  Created by Alexandre Madeira on 28/01/22.
//

import Foundation

struct Network: Decodable, Identifiable {
    let name: String
    let id: Int
    let logoPath: String?
    let originCountry: String
}
