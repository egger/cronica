//
//  ProductionCompany.swift
//  Story
//
//  Created by Alexandre Madeira on 21/01/22.
//

import Foundation

struct ProductionCompany: Decodable {
    let id: Int?
    let logoPath, name, originCountry: String?
}
