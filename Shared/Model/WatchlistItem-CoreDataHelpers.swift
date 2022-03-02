//
//  WatchlistItem-CoreDataHelpers.swift
//  Story
//
//  Created by Alexandre Madeira on 15/02/22.
//

import Foundation

extension WatchlistItem {
    enum SortOrder {
        case status, date
    }
    
    var itemTitle: String {
        title ?? NSLocalizedString("No title available", comment: "Title couldn't be found.")
    }
    
    var itemId: Int {
        Int(id)
    }
    
    var media: MediaType {
        switch contentType {
        case 0:
            return MediaType.movie
        case 1:
            return MediaType.tvShow
        case 2:
            return MediaType.person
        default:
            return MediaType.movie
        }
    }
    
    static var example: WatchlistItem {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext
        let item = WatchlistItem(context: viewContext)
        item.title = Movie.previewMovie.title
        item.id = Int32(Movie.previewMovie.id)
        item.image = Movie.previewMovie.backdropImage
        item.contentType = 0
        return item
    }
}

enum StyleType: Decodable {
    case poster
    case card
}

enum MediaType: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case movie, person
    case tvShow = "tv"
    var title: String {
        switch self {
        case .movie:
            return "Movie"
        case .tvShow:
            return "TV Show"
        case .person:
            return "People"
        }
    }
}
