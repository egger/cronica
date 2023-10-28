//
//  SearchViewModel.swift
//  Cronica
//
//  Created by Alexandre Madeira on 06/03/22.
//

import Foundation
import SwiftUI

@MainActor class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    private var service: NetworkService = NetworkService.shared
    var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    private var page = 1
    @Published var items = [SearchItemContent]()
    @Published var startPagination: Bool = false
    @Published var endPagination: Bool = false
	@Published var trendingPeople = [Person]()
	@Published var isLoadingTrendingPeople = true
	private var keywords: [CombinedKeywords] = [
		.init(id: 210024, name: NSLocalizedString("Anime", comment: ""), image: nil),
		.init(id: 41645, name: NSLocalizedString("Based on Video-Game", comment: ""), image: nil),
		.init(id: 9715, name: NSLocalizedString("Superhero", comment: ""), image: nil),
		.init(id: 9799, name: NSLocalizedString("Romantic Comedy", comment: ""), image: nil),
		.init(id: 9672, name: NSLocalizedString("Based on true story", comment: ""), image: nil),
		.init(id: 256183, name: NSLocalizedString("Supernatural Horror", comment: ""), image: nil),
		.init(id: 10349, name: NSLocalizedString("Survival", comment: ""), image: nil),
		.init(id: 9882, name: NSLocalizedString("Space", comment: ""), image: nil),
		.init(id: 818, name: NSLocalizedString("Based on novel or book", comment: ""), image: nil),
		.init(id: 9951, name: NSLocalizedString("Alien", comment: ""), image: nil),
		.init(id: 189402, name: NSLocalizedString("Crime Investigation", comment: ""), image: nil),
		.init(id: 161184, name: NSLocalizedString("Reboot", comment: ""), image: nil),
		.init(id: 15285, name: NSLocalizedString("Spin off", comment: ""), image: nil)
	]
	@Published var trendingKeywords = [CombinedKeywords]()
	@Published var isLoadingTrendingKeywords = true
    @Published var stage: SearchStage = .none
    
    func search(_ query: String) async {
        if Task.isCancelled { return }
        if query.isEmpty {
            startPagination = false
            withAnimation {
                items.removeAll()
                stage = .none
            }
            return
        }
        withAnimation { stage = .searching }
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }
        do {
            if Task.isCancelled {
                withAnimation { stage = .none }
                return
            }
            try await Task.sleep(nanoseconds: 300_000_000)
            if !items.isEmpty {
                items.removeAll()
            }
            // restart pagination values
            page = 1
            endPagination = false
            let result = try await service.search(query: trimmedQuery, page: "1")
            page += 1
            if SettingsStore.shared.disableSearchFilter {
                items.append(contentsOf: result.sorted(by: { $0.itemPopularity > $1.itemPopularity }))
            } else {
                let filtered = await filter(for: result)
                items.append(contentsOf: filtered.sorted(by: { $0.itemPopularity > $1.itemPopularity }))
            }
            if self.items.isEmpty {
                withAnimation { stage = .empty }
                return
            }
            withAnimation {  stage = .success }
            startPagination = true
        } catch {
            if Task.isCancelled { return }
            withAnimation { stage = .failure }
            CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                  for: "SearchViewModel.search()")
        }
    }
    
    func loadMoreItems() {
        if Task.isCancelled { return }
        if items.isEmpty { return }
        if endPagination { return }
        if Task.isCancelled { return }
        Task {
            let result = try? await service.search(query: trimmedQuery, page: "\(page)")
            guard let result else { return }
            if result.isEmpty { endPagination.toggle() }
            let filtered = await filter(for: result)
            withAnimation {
                self.items.append(contentsOf: filtered.sorted(by: { $0.itemPopularity > $1.itemPopularity }))
            }
            self.page += 1
        }
    }
	
	func loadTrendingPeople() async {
		if trendingPeople.isEmpty {
			do {
				let result = try await service.fetchPersons(from: "trending/person/week")
				let filtered = result.filter { $0.profilePath != nil && $0.isAdult == false }
				trendingPeople = filtered
				isLoadingTrendingPeople = false
			} catch {
				if Task.isCancelled { return }
				let message = "Can't load trending/person/week, error: \(error.localizedDescription)"
				CronicaTelemetry.shared.handleMessage(message, for: "SearchViewModel.loadTrendingPeople()")
			}
		}
	}
	
	func loadTrendingKeywords() async {
		if trendingKeywords.isEmpty {
			for item in keywords.sorted(by: { $0.name < $1.name}) {
				let itemFromKeyword = try? await service.fetchKeyword(type: .movie,
																	  page: 1,
																	  keywords: item.id,
																	  sortBy: TMDBSortBy.popularity.rawValue)
				var url: URL?
				if let firstItem = itemFromKeyword?.first {
					url = firstItem.cardImageMedium
				}
				let content: CombinedKeywords = .init(id: item.id, name: item.name, image: url)
				trendingKeywords.append(content)
			}
			withAnimation {
				isLoadingTrendingKeywords = false
			}
		}
	}
	
	
    private func filter(for items: [SearchItemContent]) async -> [SearchItemContent] {
        var result = [SearchItemContent]()
        for item in items {
            let contentKeywords = try? await service.fetchKeywords(type: item.itemContentMedia, id: item.id)
            if let contentKeywords {
                var keywordsArray = [Int]()
                let _: [()] = contentKeywords.map { item in
                    keywordsArray.append(item.id)
                }
                let containsNSFW = !Set(keywordsArray).isDisjoint(with: nsfwKeywords)
                if !containsNSFW {
                    result.append(item)
                }
            } else {
                result.append(item)
            }
        }
        return result
    }
}

enum SearchStage: String {
    var id: String { rawValue }
    case none, failure, empty, success, searching
}

struct CombinedKeywords: Identifiable, Hashable {
	let id: Int
	let name: String
	let image: URL?
}

