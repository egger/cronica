//
//  Person-Extensions.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 24/03/22.
//

import Foundation

extension Person {
    var isAdult: Bool {
        adult ?? true
    }
    var personImage: URL? {
        return NetworkService.urlBuilder(size: .medium, path: profilePath)
    }
    var personBiography: String {
        if let biography {
            if biography.isEmpty {
                return NSLocalizedString("No biography available.", comment: "")
            } else {
                return biography
            }
        }
        return NSLocalizedString("No biography available.", comment: "")
    }
    var personRole: String? {
        job ?? character
    }
    var itemPopularity: Double {
        return popularity ?? 0.00
    }
    var itemURL: URL {
        return URL(string: "https://www.themoviedb.org/person/\(id)")!
    }
    var itemUrlProxy: String {
        return  "https://www.themoviedb.org/person/\(id)"
    }
    static var example: [Person] {
        return ItemContent.previewContent.credits!.cast
    }
    static var previewCast: Person {
        return example[2]
    }
}
