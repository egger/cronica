//
//  NetworkService.swift
//  Story
//
//  Created by Alexandre Madeira on 20/01/22.
//  swiftlint:disable trailing_whitespace

import Foundation

class NetworkService {
    static let shared = NetworkService()
    
    /// Fetch a single content from a given Id and media type.
    func fetchContent(id: Content.ID, type: MediaType) async throws -> Content {
        guard let url = urlBuilder(path: "\(type.rawValue)/\(id)",
                                   params: ["append_to_response":"credits,recommendations"],
                                   langCode: ["language":"\(Utilities.userLang)"]
        ) else {
            throw NetworkError.invalidEndpoint
        }
        print(url)
        return try await self.fetch(url: url)
    }
    
    func fetchSeason(id: Int, season: Int) async throws -> Season {
        guard let url = urlBuilder(path: "\(MediaType.tvShow.rawValue)/\(id)/season/\(season)",
                                   langCode: ["language":"en-US"]
        ) else {
            throw NetworkError.invalidEndpoint
        }
        print(url)
        return try await self.fetch(url: url)
    }
    
    /// Fetch a list of content from a given endpoint.
    func fetchContents(from path: String) async throws -> [Content] {
        guard let url = urlBuilder(path: "\(path)",
                                   langCode: ["language":"\(Utilities.userLang)"]) else {
            throw NetworkError.invalidEndpoint
        }
        print(url)
        let response: ContentResponse = try await self.fetch(url: url)
        return response.results
    }
    
    func fetchPerson(id: Person.ID) async throws -> Person {
        guard let url = urlBuilder(path: "person/\(id)",
                                   params: ["append_to_response":"combined_credits"],
                                   langCode: ["language":"\(Utilities.userLang)"]
        ) else {
            throw NetworkError.invalidEndpoint
        }
        return try await self.fetch(url: url)
    }
    
    func search(query: String) async throws -> [Content] {
        guard let url = urlBuilder(path: "search/multi",
                                   params: [
                                    "language":"\(Utilities.userLang)",
                                    "include_adult":"false",
                                    "query":"\(query)"
                                   ],
                                   langCode: ["language":"\(Utilities.userLang)"]
        ) else {
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
    /// - Parameters:
    ///   - path: Content type and the ID for the content.
    ///   - params: Additional information to display in the Details' pages.
    /// - Returns: A safe URL, can be nil.
    private func urlBuilder(path: String, params: [String:String]? = nil, langCode: [String:String]? = nil) -> URL? {
        var component = URLComponents()
        component.scheme = "https"
        component.host = "api.themoviedb.org"
        component.path = "/3/\(path)"
        var queryItems = [URLQueryItem(name: "api_key", value: Key.keyV3)]
        if let langCode = langCode {
            queryItems.append(contentsOf: langCode.map { URLQueryItem(name: $0.key, value: $0.value) })
        }
        if let params = params {
            queryItems.append(contentsOf: params.map { URLQueryItem(name: $0.key, value: $0.value) })
        }
        component.queryItems = queryItems
        return component.url
    }
}
