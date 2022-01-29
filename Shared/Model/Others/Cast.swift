//
//  Cast.swift
//  Story
//
//  Created by Alexandre Madeira on 21/01/22.
//

import Foundation

struct Cast: Decodable, Identifiable {
    let id: Int
    let name: String
    let adult: Bool?
    let gender: Int?
    let knownForDepartment: Department?
    let biography, birthday, originalName: String?
    let popularity: Double?
    private let profilePath: String?
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
