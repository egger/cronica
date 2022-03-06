//
//  SearchItem.swift
//  Story
//
//  Created by Alexandre Madeira on 06/03/22.
//

import Foundation


struct SearchResponse: Identifiable, Decodable {
    var id = UUID()
    
    let page: Int
    let results: [SearchItem]
    let totalPages, totalResults: Int
}

struct SearchItem: Identifiable, Decodable {
    let adult: Bool?
    let backdropPath, posterPath, profilePath: String?
    let id: Int
    let mediaType: SearchMediaType
    let title, name: String?
}

enum SearchMediaType: Decodable {
    case movie, tv, person
}

extension SearchItem {
    var itemTitle: String {
        title ?? name!
    }
    var cardImage: URL? {
        if backdropPath != nil {
            return URL(string: "\(ApiConstants.w500ImageUrl)\(backdropPath!)")!
        } else {
            return nil
        }
    }
    var image: URL? {
        switch media {
        case .movie:
            return URL(string: "\(ApiConstants.w500ImageUrl)\(backdropPath!)")!
        case .tvShow:
            return URL(string: "\(ApiConstants.w500ImageUrl)\(backdropPath!)")!
        case .person:
            return URL(string: "\(ApiConstants.w500ImageUrl)\(profilePath!)")!
        }
    }
    var media: MediaType {
        switch mediaType {
        case .movie:
            return MediaType.movie
        case .person:
            return MediaType.person
        case .tv:
            return MediaType.tvShow
        }
    }
}
