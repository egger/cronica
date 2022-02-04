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
    let adult : Bool?
    let id : Int
    let name : String
    private let profilePath : String?
    let cast_id : Int?
    private let character : String?
    let order : Int?
    let biography, birthday, knownForDepartment: String?
    var profileImage: URL {
        return URL(string: "\(ApiConstants.w500ImageUrl)\(profilePath ?? "")")!
    }
    var role: String {
        if character != nil {
            return character!
        } else {
            return "n/a"
        }
    }
    enum CodingKeys: String, CodingKey {
        case adult = "adult"
        case id = "id"
        case name = "name"
        case profilePath = "profilePath"
        case cast_id = "cast_id"
        case character = "character"
        case order = "order"
        case biography, birthday
        case knownForDepartment = "known_for_department"
    }
}

struct Crew : Decodable, Identifiable {
    let adult : Bool?
    let gender : Int?
    let id : Int
    let name : String
    let original_name : String?
    let profile_path : String?
    let department : String?
    private let job : String?
    var profileImage: URL {
        return URL(string: "\(ApiConstants.w500ImageUrl)\(String(describing: profile_path))" )!
    }
    var role: String {
        if job != nil {
            return job!
        } else {
            return "n/a"
        }
    }
    enum CodingKeys: String, CodingKey {
        case adult = "adult"
        case gender = "gender"
        case id = "id"
        case name = "name"
        case original_name = "original_name"
        case profile_path = "profile_path"
        case department = "department"
        case job = "job"
    }
}

