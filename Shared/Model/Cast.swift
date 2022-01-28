//
//  Cast.swift
//  Story
//
//  Created by Alexandre Madeira on 21/01/22.
//

import Foundation

struct Cast: Decodable, Identifiable {
    let adult: Bool?
    let gender, id: Int?
    let knownForDepartment: Department?
    let name, originalName: String?
    let biography, birthday: String?
    let popularity: Double?
    let profilePath: String?
    let castID: Int?
    let character: String?
    let creditID: String?
    let order: Int?
    let department: Department?
    let job: String?
    var profileImage: URL {
        return URL(string: "\(ApiConstants.w500ImageUrl)\(profilePath ?? "")")!
    }
}
