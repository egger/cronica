//
//  NetworkService.swift
//  Story
//
//  Created by Alexandre Madeira on 20/01/22.
//  swiftlint:disable trailing_whitespace

import Foundation

class NetworkService {
    static let shared = NetworkService()
    
    func fetchContent(id: Content.ID, type: MediaType) async throws -> Content {
        guard let url = urlBuilder(path: "\(type.rawValue)/\(id)", append: type.append) else {
            throw NetworkError.invalidEndpoint
        }
        return try await self.fetch(url: url)
    }
    
    func fetchSeason(id: Int, season: Int) async throws -> Season {
        guard let url = urlBuilder(path: "\(MediaType.tvShow.rawValue)/\(id)/season/\(season)") else {
            throw NetworkError.invalidEndpoint
        }
        return try await self.fetch(url: url)
    }
    
    func fetchContents(from path: String) async throws -> [Content] {
        guard let url = urlBuilder(path: path) else {
            throw NetworkError.invalidEndpoint
        }
        let response: ContentResponse = try await self.fetch(url: url)
        return response.results
    }
    
    func fetchPerson(id: Person.ID) async throws -> Person {
        guard let url = urlBuilder(path: "person/\(id)", append: "combined_credits")
        else {
            throw NetworkError.invalidEndpoint
        }
        return try await self.fetch(url: url)
    }
    
    func search(query: String) async throws -> [Content] {
        guard let url = urlBuilder(path: "search/multi", query: query) else {
            throw NetworkError.invalidEndpoint
        }
        let results: ContentResponse = try await self.fetch(url: url)
        return results.results
    }
    
    private func fetch<T: Decodable>(url: URL) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
                  throw NetworkError.invalidResponse
              }
        return try Utilities.decoder.decode(T.self, from: data)
    }
    
    /// Build a safe URL for the TMDB API Service.
    ///
    /// Use it to load lists, details, search.
    /// - Parameters:
    ///   - path: Content type and the ID for the content.
    ///   - append: Additional information to display in the Details' pages.
    ///   - query: The query for the search functionality.
    /// - Returns: A safe URL, can be nil.
    private func urlBuilder(path: String, append: String? = nil, query: String? = nil) -> URL? {
        var component = URLComponents()
        component.scheme = "https"
        component.host = "api.themoviedb.org"
        component.path = "/3/\(path)"
        if let append = append {
            component.queryItems = [
                .init(name: "api_key", value: Key.keyV3),
                .init(name: "language", value: Utilities.userLang),
                .init(name: "append_to_response", value: append)
            ]
        }
        else {
            component.queryItems = [
                .init(name: "api_key", value: Key.keyV3),
                .init(name: "language", value: Utilities.userLang),
                .init(name: "region", value: Utilities.userRegion)
            ]
        }
        if let query = query {
            component.queryItems = [
                .init(name: "api_key", value: Key.keyV3),
                .init(name: "language", value: Utilities.userLang),
                .init(name: "query", value: query),
                .init(name: "include_adult", value: "false"),
                .init(name: "region", value: Utilities.userRegion)
            ]
        }
        print("URL Builder: \(component.url as Any)")
        return component.url
    }
    
    /// Build a safe URL for the images used on TMDB API.
    ///
    /// Use it build only the urls responsible to the images.
    /// - Parameters:
    ///   - size: The image size returned in the url.
    ///   - path: The path for the given image.
    /// - Returns: A safe URL, can be nil.
    static func urlBuilder(size: ImageSize, path: String? = nil) -> URL? {
        if let path = path {
            var component = URLComponents()
            component.scheme = "https"
            component.host = "image.tmdb.org"
            component.path = "/\(size.rawValue)\(path)"
            return component.url
        } else {
            return nil
        }
    }
}

enum NetworkError: Error, CustomNSError {
    case invalidResponse, invalidRequest, invalidEndpoint, decodingError
}
