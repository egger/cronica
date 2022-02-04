//
//  MoviesDetailsViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 28/01/22.
//

import Foundation
import UIKit

@MainActor
class MoviesDetailsViewModel: ObservableObject {
    private let service: NetworkService = NetworkService.shared
    @Published private(set) var phase: DataFetchPhase<Movie?> = .empty
    var movie: Movie? {
        phase.value ?? nil
    }
    var holdedMovie: Movie?
    
    func share() {
        let shareSheetVC = UIActivityViewController(
            activityItems: [
                movie?.title as Any,
                movie?.shareLink as Any
            ],
            applicationActivities: nil)
        let scenes = UIApplication.shared.connectedScenes
        let windowScenes = scenes.first as? UIWindowScene
        let window = windowScenes?.windows.first
        window?.rootViewController!.present(shareSheetVC, animated: true)
    }
    
    func loadMovie(id: Int) async {
        if Task.isCancelled { return }
        phase = .empty
        do {
            let movie = try await self.service.fetchMovie(id: id)
            phase = .success(movie)
        } catch {
            phase = .failure(error)
        }
    }
    
    
}
