//
//  Bundle-Decodable.swift
//  Story
//
//  Created by Alexandre Madeira on 17/01/22.
//

import Foundation

extension Bundle {
    func decode<T: Decodable>(from file: String) throws -> T? {
        guard let url = self.url(forResource: file, withExtension: "json") else {
            fatalError("Failed to locate \(file) from bundle.")
        }
        let data = try Data(contentsOf: url)
        let result = try Util.decoder.decode(T.self, from: data)
        return result
    }
}
