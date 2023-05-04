//
//  ItemContent.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 26/08/22.
//

import Foundation

struct ItemContent: Identifiable, Decodable, Hashable {
    var id: Int
    let title, name, posterPath, backdropPath: String?
    let data: Data?
    var placeholderImagePath: String?
}
struct ItemContentResponse: Identifiable, Decodable, Hashable {
    let id: String?
    let results: [ItemContent]
}
struct ItemContentKeyword: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
}

struct Keywords: Hashable, Codable {
    let keywords: [ItemContentKeyword]
}
