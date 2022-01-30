//
//  Cast.swift
//  Story
//
//  Created by Alexandre Madeira on 29/01/22.
//

import Foundation

struct Cast : Decodable, Identifiable {
    let adult : Bool?
    let gender : Int?
    let id : Int
    let known_for_department : String?
    let name : String?
    let original_name : String?
    let profilePath : String?
    let cast_id : Int?
    let character : String?
    let credit_id : String?
    let order : Int?
    var profileImage: URL {
        return URL(string: "\(ApiConstants.w500ImageUrl)\(profilePath ?? "")")!
    }
    enum CodingKeys: String, CodingKey {
        case adult = "adult"
        case gender = "gender"
        case id = "id"
        case known_for_department = "knownForDepartment"
        case name = "name"
        case original_name = "originalName"
        case profilePath = "profilePath"
        case cast_id = "cast_id"
        case character = "character"
        case credit_id = "creditId"
        case order = "order"
    }
}
