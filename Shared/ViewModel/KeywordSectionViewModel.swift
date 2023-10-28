//
//  KeywordSectionViewModel.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 10/08/23.
//

import SwiftUI

@MainActor
class KeywordSectionViewModel: ObservableObject {
	private var page = 1
	@Published var items = [ItemContent]()
	@Published var isLoaded = false
	@Published var startPagination = false
	@Published var endPagination = false
	private let network = NetworkService.shared
	
	func load(_ id: Int, sortBy: TMDBSortBy, reload: Bool) async {
		do {
			if reload {
				withAnimation {
					items.removeAll()
					isLoaded = false
					page = 1
				}
			}
			let movies = try await network.fetchKeyword(type: .movie,
														page: page,
														keywords: id,
														sortBy: sortBy.rawValue)
			let shows = try await network.fetchKeyword(type: .tvShow,
													   page: page,
													   keywords: id,
													   sortBy: sortBy.rawValue)
			let result = movies + shows
			if result.isEmpty {
				endPagination = true
				return
			} else {
				page += 1
			}
			withAnimation {
				items.append(contentsOf: result.sorted { $0.itemPopularity > $1.itemPopularity })
			}
			if !startPagination { startPagination = true }
			if !isLoaded {
				await MainActor.run {
					self.isLoaded = true
				}
			}
		} catch {
			if Task.isCancelled { return }
			let message = "Keyword ID: \(id), error: \(error.localizedDescription)"
			CronicaTelemetry.shared.handleMessage(message, for: "KeywordSectionViewModel.load()")
		}
	}
}
