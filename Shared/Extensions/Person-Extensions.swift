//
//  Person-Extensions.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 24/03/22.
//

import Foundation

extension Person {
    var itemImage: URL? {
        return NetworkService.urlBuilder(size: .medium, path: profilePath)
    }
    var itemBiography: String {
        if let biography = biography {
            return biography
        }
        return "Not Available" 
    }
    var itemRole: String? {
        job ?? character
    }
    var itemURL: URL {
        return URL(string: "https://www.themoviedb.org/person/\(id)")!
    }
}
