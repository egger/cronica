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
        guard let url = urlBuilder(path: "movie/\(endpoint.rawValue)") else {
            throw NetworkError.invalidEndpoint
        }
        let response: MovieResponse = try await self.fetch(url: url)
        return response.results
    }
    
    func fetchMovie(id: Movie.ID) async throws -> Movie {
        guard let url = urlBuilder(path: "movie/\(id)",
                                   params: ["append_to_response": "credits,similar"]
        ) else {
            throw NetworkError.invalidEndpoint
        }
        return try await self.fetch(url: url)
    }
    
    func fetchTvShows(from endpoint: SeriesEndpoint) async throws -> [TVShow] {
        guard let url = urlBuilder(path: "tv/\(endpoint.rawValue)") else {
            throw NetworkError.invalidEndpoint
        }
        let response: TVResponse = try await self.fetch(url: url)
        return response.results
    }
    
    func fetchTvShow(id: TVShow.ID) async throws -> TVShow {
        guard let url = urlBuilder(path: "tv/\(id)",
                                   params: ["append_to_response": "credits,similar"]
        ) else {
            throw NetworkError.invalidEndpoint
        }
        return try await self.fetch(url: url)
    }
    
    func fetchPerson(id: Person.ID) async throws -> Person {
        guard let url = urlBuilder(path: "person/\(id)",
                                   params: ["append_to_response": "combined_credits"]
        ) else {
            throw NetworkError.invalidEndpoint
        }
        return try await self.fetch(url: url)
    }
    
    private func fetch<T: Decodable>(url: URL) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
                  throw NetworkError.invalidResponse
              }
        
        return try Util.jsonDecoder.decode(T.self, from: data)
    }
    
    private func urlBuilder(path: String, params: [String:String]? = nil) -> URL? {
        var component = URLComponents()
        component.scheme = "https"
        component.host = "api.themoviedb.org"
        component.path = "/3/\(path)"
        var queryItems = [URLQueryItem(name: "api_key", value: ApiConstants.apiKey3)]
        if let params = params {
            queryItems.append(contentsOf: params.map { URLQueryItem(name: $0.key, value: $0.value) })
        }
        component.queryItems = queryItems
        print(component.url as Any)
        return component.url
    }
}
