//
//  Credits.swift
//  Story
//
//  Created by Alexandre Madeira on 21/01/22.
//

import Foundation

struct Credits: Decodable {
    let cast, crew: [Person]
}

struct Person: Decodable, Identifiable {
    let id: Int
    let name: String
    let job, character, biography, birthday: String?
    private let profilePath: String?
    let combinedCredits: CombinedCredits?
}

struct CombinedCredits: Decodable {
    let cast, crew: [Filmography]?
}

struct Filmography: Decodable, Identifiable {
    let id: Int
    private let title, character: String?
    let backdropPath, posterPath, releaseDate: String?
    let overview: String
}

extension Person {
    var image: URL? {
        if profilePath == nil {
            return nil
        } else {
            return URL(string: "\(ApiConstants.originalImageUrl)\(profilePath!)")!
        }
    }
    var w500Image: URL? {
        if profilePath == nil {
            return nil
        } else {
            return URL(string: "\(ApiConstants.w500ImageUrl)\(profilePath!)")!
        }
    }
    var role: String? {
        if job != nil {
            return job!
        }
        else if character != nil {
            return character!
        }
        else {
            return nil
        }
    }
}

extension Filmography {
    var itemTitle: String {
        title ?? "N/A"
    }
    var image: URL? {
        if posterPath != nil {
            return URL(string: "\(ApiConstants.originalImageUrl)\(posterPath!)")!
        } else {
            return nil
        }
    }
}
