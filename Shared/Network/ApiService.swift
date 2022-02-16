//
//  ApiService.swift
//  Story
//
//  Created by Alexandre Madeira on 22/01/22.
//

import Foundation

protocol ApiService {
    func fetchMovies(from endpoint: MovieEndpoints) async throws -> [Movie]
    func fetchMovie(id: Int) async throws -> Movie
    func fetchTvShows(from endpoint: SeriesEndpoint) async throws -> [TVShow]
    func fetchTvShow(id: Int) async throws -> TVShow
    func fetchPerson(id: Int) async throws -> Person
}
