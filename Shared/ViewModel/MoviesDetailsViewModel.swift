//
//  MoviesDetailsViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 28/01/22.
//

import Foundation
//import UIKit

@MainActor
class MoviesDetailsViewModel: ObservableObject {
    private let service: NetworkService = NetworkService.shared
    @Published private(set) var phase: DataFetchPhase<Movie?> = .empty
    var movie: Movie? {
        phase.value ?? nil
    }
    
    func loadMovie(id: Int) async {
        if Task.isCancelled { return }
        phase = .empty
        do {
            let movie = try await self.service.fetchMovie(id: id)
            print(movie.similar as Any)
            phase = .success(movie)
        } catch {
            phase = .failure(error)
        }
    }
}
