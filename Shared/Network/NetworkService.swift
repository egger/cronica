//
//  NetworkService.swift
//  Story
//
//  Created by Alexandre Madeira on 20/01/22.
//  swiftlint:disable trailing_whitespace

import Foundation
import os

class NetworkService {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: NetworkService.self)
    )
    static let shared = NetworkService()
    private let decoder = JSONDecoder()
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy,MM,dd"
        return formatter
    }()
    
    private init() {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(NetworkService.dateFormatter)
    }
    
    func fetchItem(id: ItemContent.ID, type: MediaType) async throws -> ItemContent {
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
    
    func fetchItems(from path: String, page: String = "1") async throws -> [ItemContent] {
        guard let url = urlBuilder(path: path, page: page) else {
            throw NetworkError.invalidEndpoint
        }
        let response: ItemContentResponse = try await self.fetch(url: url)
        return response.results
    }
    
    func fetchDiscover(type: MediaType, page: Int, genres: String, sort: DiscoverSortBy) async throws -> [ItemContent] {
        guard let url = urlBuilder(type: type.rawValue, page: page, genres: genres, sortBy: sort) else {
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
    
    func fetchProviders(id: ItemContent.ID, for media: MediaType) async throws -> WatchProviders {
        guard let url = urlBuilder(path: "\(media.rawValue)/\(id)/watch/providers")
        else {
            throw NetworkError.invalidRequest
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
        guard let url else { return nil}
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            return nil
        }
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
                .init(name: "language", value: Locale.userLang),
                .init(name: "page", value: page),
                .init(name: "append_to_response", value: append)
            ]
        } else {
            component.queryItems = [
                .init(name: "api_key", value: Key.tmdbApi),
                .init(name: "language", value: Locale.userLang),
                .init(name: "region", value: Locale.userRegion),
                .init(name: "page", value: page)
            ]
        }
        if let query {
            component.queryItems = [
                .init(name: "api_key", value: Key.tmdbApi),
                .init(name: "language", value: Locale.userLang),
                .init(name: "query", value: query),
                .init(name: "page", value: page),
                .init(name: "include_adult", value: "false"),
                .init(name: "region", value: Locale.userRegion)
            ]
        }
        return component.url
    }
    
    /// Build a safe URL for the TMDb's Discovery endpoint.
    /// - Parameters:
    ///   - type: The content type for the discovery fetch.
    ///   - page: The page used for pagination.
    ///   - genres: The desired genres for the discovery.
    private func urlBuilder(type: String, page: Int, genres: String, sortBy: DiscoverSortBy) -> URL? {
        var component = URLComponents()
        component.scheme = "https"
        component.host = "api.themoviedb.org"
        component.path = "/3/discover/\(type)"
        component.queryItems = [
            .init(name: "api_key", value: Key.tmdbApi),
            .init(name: "language", value: Locale.userLang),
            .init(name: "region", value: Locale.userRegion),
            .init(name: "sort_by", value: sortBy.rawValue),
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
    
    static func fetchVideos(for videos: [VideosResult]? = nil) -> [VideoItem]? {
        guard let videos else { return nil }
        var items: [VideoItem] = []
        for video in videos {
            if video.isTrailer {
                items.append(VideoItem.init(url: urlBuilder(video: video.key),
                                            thumbnail: fetchThumbnail(for: video.key),
                                            title: video.name))
            }
        }
        return items
    }
    
    /// Build a URL for the trailer, only generate YouTube links.
    /// - Parameter path: The 'key' for the trailer.
    /// - Returns: Returns nil if the path is nil, otherwise return a safe URL.
    private static func urlBuilder(video path: String? = nil) -> URL? {
        guard let path else { return nil }
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.youtube.com"
        components.path = "/embed/\(path)"
        return components.url
    }
    
    private static func fetchThumbnail(for id: String?) -> URL? {
        guard let id else { return nil }
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "img.youtube.com"
        urlComponents.path = "/vi/\(id)/maxresdefault.jpg"
        return urlComponents.url
    }
}
