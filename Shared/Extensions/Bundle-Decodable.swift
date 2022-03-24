//
//  Bundle-Decodable.swift
//  Story
//
//  Created by Alexandre Madeira on 17/01/22.
//

import Foundation

extension Bundle {
    var displayName: String {
        object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Could not determine the application name"
    }
    var appBuild: String {
        object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Could not determine the application build number"
    }
    var appVersion: String {
        object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Could not determine the application version"
    }
    func decode<T: Decodable>(from file: String) throws -> T? {
        guard let url = self.url(forResource: file, withExtension: "json") else {
            fatalError("Failed to locate \(file) from bundle.")
        }
        let data = try Data(contentsOf: url)
        let result = try Utilities.decoder.decode(T.self, from: data)
        return result
    }
}
