//
//  Videos.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 28/04/22.
//

import Foundation
import SwiftUI

struct Videos: Codable, Hashable {
    let results: [VideosResult]
}
struct VideosResult: Codable, Hashable {
    let iso639_1, iso3166_1, id: String?
    let name, key, type: String
    let official: Bool
}
struct Trailer: Identifiable, Codable, Hashable {
    var id = UUID()
    let url: URL?
    let thumbnail: URL?
    let title: String
}
