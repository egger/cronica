//
//  Credits.swift
//  Story
//
//  Created by Alexandre Madeira on 21/01/22.
//

import Foundation

struct Credits: Decodable {
    let cast : [Cast]
    let crew : [Crew]
    enum CodingKeys: String, CodingKey {
        case cast = "cast"
        case crew = "crew"
    }
}

struct Cast : Decodable, Identifiable {
    let id : Int
    let name : String
    private let profilePath, character : String?
    let cast_id, order : Int?
    let biography: String?
    var image: URL? {
        if profilePath == nil {
            return nil
        } else {
            return URL(string: "\(ApiConstants.w500ImageUrl)\(profilePath!)")!
        }
    }
    var role: String? {
        if character == nil {
            return nil
        } else {
            return character!
        }
    }
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case profilePath = "profilePath"
        case cast_id = "cast_id"
        case character = "character"
        case order = "order"
        case biography
    }
}

struct Crew : Decodable, Identifiable {
    let id : Int
    let name : String
    private let profilePath, job : String?
    var image: URL? {
        if profilePath == nil {
            return nil
        } else {
            return URL(string: "\(ApiConstants.originalImageUrl)\(profilePath!)")!
        }
    }
    var role: String? {
        if job == nil {
            return nil
        } else {
            return job!
        }
    }
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case profilePath = "profilePath"
        case job = "job"
    }
}

