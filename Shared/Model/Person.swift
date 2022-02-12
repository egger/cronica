//
//  Credits.swift
//  Story
//
//  Created by Alexandre Madeira on 21/01/22.
//

import Foundation

struct Person: Decodable, Identifiable {
    let id: Int
    let name: String
    let job, character: String?
    let biography, birthday, profilePath: String?
    let cast_id, order : Int?
    var image: URL? {
        if profilePath != nil {
            return URL(string: "\(ApiConstants.originalImageUrl)\(profilePath!)")!
        } else {
            return nil
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

struct Credits: Decodable {
    let cast : [Person]
    let crew : [Person]
    enum CodingKeys: String, CodingKey {
        case cast = "cast"
        case crew = "crew"
    }
}
