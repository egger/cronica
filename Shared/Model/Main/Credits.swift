//
//  Credits.swift
//  Story
//
//  Created by Alexandre Madeira on 21/01/22.
//

import Foundation

struct Credits: Decodable, Identifiable {
    var id = UUID()
    let cast, crew: [Cast]
}

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
    let character, creditID: String?
    let order: Int?
    let department: Department?
    let job: String?
    var profileImage: URL {
        return URL(string: "\(ApiConstants.w500ImageUrl)\(profilePath ?? "")")!
    }
}

enum Department: Decodable {
    case acting, art, camera, costumeMakeUp, crew, directing, editing,
         lightning, production, sound, visualEffects, writing
}
