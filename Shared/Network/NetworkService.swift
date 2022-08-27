//
//  NetworkService.swift
//  Story
//
//  Created by Alexandre Madeira on 20/01/22.
//  swiftlint:disable trailing_whitespace

import Foundation
import TelemetryClient

class NetworkService {
    static let shared = NetworkService()
    private let decoder = JSONDecoder()
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy,MM,dd"
        return formatter
    }()
    
    init() {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(NetworkService.dateFormatter)
    }
    
    func fetchContent(id: ItemContent.ID, type: MediaType) async throws -> ItemContent {
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
    
    func fetchContents(from path: String) async throws -> [ItemContent] {
        guard let url = urlBuilder(path: path) else {
            throw NetworkError.invalidEndpoint
        }
        let response: ItemContentResponse = try await self.fetch(url: url)
        return response.results
    }
    
    func fetchDiscover(type: MediaType, page: Int, genres: String) async throws -> [ItemContent] {
        guard let url = urlBuilder(type: type.rawValue, page: page, genres: genres) else {
            throw NetworkError.invalidEndpoint
        }
        let response: ItemContentResponse = try await self.fetch(url: url)
        return response.results
    }
    
    func fetchPerson(id: Person.ID) async throws -> Person {
        guard let url = urlBuilder(path: "person/\(id)", append: "\(MediaType.person.append)")
        else {
            throw NetworkError.invalidEndpoint
        }
        return try await self.fetch(url: url)
    }
    
    func search(query: String, page: String) async throws -> [ItemContent] {
        guard let url = urlBuilder(path: "search/multi", query: query, page: page) else {
            throw NetworkError.invalidEndpoint
        }
        let results: ItemContentResponse = try await self.fetch(url: url)
        return results.results
    }
    
    private func fetch<T: Decodable>(url: URL) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else { throw NetworkError.invalidResponse }
        let responseError = handleNetworkResponses(response: httpResponse)
        if let responseError {
#if targetEnvironment(simulator)
            print(responseError as Any)
#else
            TelemetryManager.send("fetchError", with: ["error":"\(responseError.localizedName)"])
#endif
            throw responseError
        } else {
            return try decoder.decode(T.self, from: data)
        }
    }
    
    private func handleNetworkResponses(response: HTTPURLResponse) -> NetworkError? {
        switch response.statusCode {
        case 200: return nil
        case 401: return .invalidApi
        case 503: return .maintenanceApi
        case 500: return .internalError
        default: return .invalidResponse
        }
    }
    
    func downloadImageData(from url: URL?) async -> Data? {
        if let url = url {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                return data
            } catch {
                print(error as Any)
            }
        }
        return nil
    }
    
    /// Build a safe URL for the TMDB API Service.
    ///
    /// Only use it to generate the URL responsible for fetching content, such as details, lists, and search.
    /// - Parameters:
    ///   - path: The path for the fetch request.
    ///   - append: Additional information to fetch.
    ///   - query: The query for the search functionality, if in Search.
    /// - Returns: Returns nil if the path is nil, otherwise return a safe URL.
    private func urlBuilder(path: String, append: String? = nil, query: String? = nil, page: String = "1") -> URL? {
        var component = URLComponents()
        component.scheme = "https"
        component.host = "api.themoviedb.org"
        component.path = "/3/\(path)"
        if let append {
            component.queryItems = [
                .init(name: "api_key", value: Key.tmdbApi),
                .init(name: "language", value: Utilities.userLang),
                .init(name: "page", value: page),
                .init(name: "append_to_response", value: append)
            ]
        } else {
            component.queryItems = [
                .init(name: "api_key", value: Key.tmdbApi),
                .init(name: "language", value: Utilities.userLang),
                .init(name: "region", value: Utilities.userRegion)
            ]
        }
        if let query {
            component.queryItems = [
                .init(name: "api_key", value: Key.tmdbApi),
                .init(name: "language", value: Utilities.userLang),
                .init(name: "query", value: query),
                .init(name: "page", value: page),
                .init(name: "include_adult", value: "false"),
                .init(name: "region", value: Utilities.userRegion)
            ]
        }
        return component.url
    }
    
    private func urlBuilder(type: String, page: Int, genres: String) -> URL? {
        var component = URLComponents()
        component.scheme = "https"
        component.host = "api.themoviedb.org"
        component.path = "/3/discover/\(type)"
        component.queryItems = [
            .init(name: "api_key", value: Key.tmdbApi),
            .init(name: "language", value: Utilities.userLang),
            .init(name: "region", value: Utilities.userRegion),
            .init(name: "sort_by", value: "popularity.desc"),
            .init(name: "include_adult", value: "false"),
            .init(name: "include_video", value: "false"),
            .init(name: "page", value: "\(page)"),
            .init(name: "with_genres", value: genres)
        ]
        return component.url
    }
    
    /// Build a safe URL for the images used on TMDB API.
    ///
    /// Use it only to build the URLs responsible for the images.
    /// - Parameters:
    ///   - size: The image size returned in the URL.
    ///   - path: The path for the image.
    /// - Returns: Returns nil if the path is nil, otherwise return a safe URL.
    static func urlBuilder(size: ImageSize, path: String? = nil) -> URL? {
        if let path {
            var component = URLComponents()
            component.scheme = "https"
            component.host = "image.tmdb.org"
            component.path = "/\(size.rawValue)\(path)"
            return component.url
        }
        return nil
    }
}
