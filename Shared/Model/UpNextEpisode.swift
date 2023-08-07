//
//  UpNextEpisode.swift
//  Story
//
//  Created by Alexandre Madeira on 07/05/23.
//

import Foundation

struct UpNextEpisode: Identifiable, Hashable {
    let id: Int
    let showTitle: String
    let showID: Int
    let backupImage: URL?
    let episode: Episode
    let sortedDate: Date
}
