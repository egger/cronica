//
//  Crew.swift
//  Story
//
//  Created by Alexandre Madeira on 29/01/22.
//

import Foundation

struct Crew : Decodable, Identifiable {
    let adult : Bool?
    let gender : Int?
    let id : Int
    let name : String
    let original_name : String?
    let profile_path : String?
    let credit_id : String?
    let department : String?
    let job : String?
    var profileImage: URL {
        return URL(string: "\(ApiConstants.w500ImageUrl)\(profile_path ?? "")")!
    }
    enum CodingKeys: String, CodingKey {
        case adult = "adult"
        case gender = "gender"
        case id = "id"
        case name = "name"
        case original_name = "original_name"
        case profile_path = "profile_path"
        case credit_id = "credit_id"
        case department = "department"
        case job = "job"
    }
}