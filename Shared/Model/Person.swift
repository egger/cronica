//
//  Credits.swift
//  Story
//
//  Created by Alexandre Madeira on 21/01/22.
//

import Foundation
import SwiftUI

struct Credits: Codable, Hashable {
    let cast, crew: [Person]
}
struct Person: Codable, Identifiable, Hashable, Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.itemUrlProxy)
    }
    let adult: Bool?
    let id: Int
    let name: String
    let job, character, biography, profilePath: String?
    let combinedCredits: Filmography?
    let popularity: Double?
}
struct Filmography: Codable, Hashable {
    let cast, crew: [ItemContent]?
}
