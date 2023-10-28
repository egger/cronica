//
//  Person-Extensions.swift
//  Cronica (iOS)
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
    var originalPersonImage: URL? {
        return NetworkService.urlBuilder(size: .original, path: profilePath)
    }
    var hasBiography: Bool {
        guard let biography else { return false }
        if !biography.isEmpty { return true }
        return false
    }
    var personBiography: String {
        if let biography {
            if biography.isEmpty {
                return NSLocalizedString("No biography available.", comment: "")
            }
            return biography
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
    var personListID: String {
        if let personRole { return "\(id)\(personRole)" }
        return "\(id)"
    }
    static var example: [Person] {
        return ItemContent.example.credits!.cast
    }
    static var previewCast: Person {
        return example[2]
    }
}
