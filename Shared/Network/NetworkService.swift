//
//  NetworkService.swift
//  Story
//
//  Created by Alexandre Madeira on 20/01/22.
//

import Foundation

class NetworkService: ApiService {
    static let shared = NetworkService()
    
    func fetchMovies(from endpoint: MovieEndpoints) async throws -> [Movie] {
        guard let url = URL(string: "\(ApiConstants.baseUrl)/movie/\(endpoint.rawValue)") else {
            throw NetworkError.invalidEndpoint
        }
        let response: MovieResponse = try await self.fetch(url: url)
        return response.results
    }
    
    func fetchTvShows(from endpoint: SeriesEndpoint) async throws -> [TvShow] {
        guard let url = URL(string: "\(ApiConstants.baseUrl)/tv/\(endpoint.rawValue)") else {
            throw NetworkError.invalidEndpoint
        }
        let response: TvResponse = try await self.fetch(url: url)
        return response.results
    }
    
    ///  Get information about a given title, credits will be send back as well.
    /// - Parameter id: Id for the given title.
    /// - Returns: Movie object.
    func fetchMovie(id: Int) async throws -> Movie {
        guard let url = URL(string: "\(ApiConstants.baseUrl)/movie/\(id)") else {
            throw NetworkError.invalidEndpoint
        }
        return try await self.fetch(url: url,
                                    params: [
                                        "append_to_response": "credits,similar"
                                    ])
    }
    
    func fetchTvShow(id: Int) async throws -> TvShow {
        guard let url = URL(string: "\(ApiConstants.baseUrl)/tv/\(id)") else {
            throw NetworkError.invalidEndpoint
        }
        return try await self.fetch(url: url,
                                    params: [
                                        :
//                                        "append_to_response": "credits"
                                    ])
    }
    
    func fetchMovieSearch(query: String) async throws -> [Movie] {
        guard let url = URL(string: "\(ApiConstants.baseUrl)/search/movie") else {
            throw NetworkError.invalidEndpoint
        }
        let response: MovieResponse = try await fetch(url: url,
                                                      params: [
                                                        "language": "en-US",
                                                        "include_adult": "false",
                                                        "region": "US",
                                                        "query": query
                                                      ])
        return response.results
    }
    
    func fetchCast(id: Int) async throws -> Cast {
        guard let url = URL(string: "\(ApiConstants.baseUrl)/person/\(id)") else {
            throw NetworkError.invalidEndpoint
        }
        return try await self.fetch(url: url, params: [:])
    }
    
    private func fetch<T: Decodable>(url: URL, params: [String: String]? = nil) async throws -> T {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidEndpoint
        }
        
        var queryItems = [URLQueryItem(name: "api_key", value: ApiConstants.apiKey3)]
        if let params = params {
            queryItems.append(contentsOf: params.map { URLQueryItem(name: $0.key, value: $0.value) })
        }
        
        components.queryItems = queryItems
        
        guard let finalUrl = components.url else {
            throw NetworkError.invalidEndpoint
        }
        print(finalUrl)
        
        let (data, response) = try await URLSession.shared.data(from: finalUrl)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        return try Util.jsonDecoder.decode(T.self, from: data)
    }
}
