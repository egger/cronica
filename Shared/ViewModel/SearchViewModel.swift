//
//  SearchViewModel.swift
//  Story
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
		.init(id: 210024, name: "Anime", image: nil),
		.init(id: 41645, name: "Based on Video-Game", image: nil),
		.init(id: 9715, name: "Superhero", image: nil),
		.init(id: 9799, name: "Romantic Comedy", image: nil),
		.init(id: 9672, name: "Based on true story", image: nil),
		.init(id: 256183, name: "Supernatural Horror", image: nil),
		.init(id: 10349, name: "Survival", image: nil),
		.init(id: 9882, name: "Space", image: nil),
		.init(id: 818, name: "Based on novel or book", image: nil),
		.init(id: 9951, name: "Alien", image: nil),
		.init(id: 189402, name: "Crime Investigation", image: nil),
		.init(id: 161184, name: "Reboot", image: nil),
		.init(id: 15285, name: "Spin off", image: nil)
	]
	@Published var trendingKeywords = [CombinedKeywords]()
	@Published var isLoadingTrendingKeywords = true
    var stage: SearchStage = .none
    
    func search(_ query: String) async {
        if Task.isCancelled { return }
        if query.isEmpty {
            startPagination = false
            withAnimation {
                items.removeAll()
            }
            stage = .none
            return
        }
        stage = .searching
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }
        do {
            if Task.isCancelled {
                stage = .none
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
            let filtered = await filter(for: result)
            items.append(contentsOf: filtered.sorted(by: { $0.itemPopularity > $1.itemPopularity }))
            if self.items.isEmpty {
                stage = .empty
                return
            }
            stage = .success
            startPagination = true
        } catch {
            if Task.isCancelled { return }
            stage = .failure
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
			var result = [CombinedKeywords]()
			for item in keywords {
				let type: MediaType = Bool.random() ? .movie : .tvShow
				let itemFromKeyword = try? await service.fetchKeyword(type: type,
																	  page: 1,
																	  keywords: item.id,
																	  sortBy: KeywordsSearchSortBy.popularity.rawValue)
				var url: URL?
				if let firstItem = itemFromKeyword?.shuffled().first {
					url = firstItem.cardImageMedium
				}
				let content: CombinedKeywords = .init(id: item.id, name: item.name, image: url)
				result.append(content)
				isLoadingTrendingKeywords = false
			}
			if !result.isEmpty {
				withAnimation {
					trendingKeywords.append(contentsOf: result.sorted(by: { $0.name < $1.name}))
				}
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
enum KeywordsSearchSortBy: String, Identifiable, CaseIterable {
	var id: String { rawValue }
	case popularity = "popularity.desc"
	case rating = "vote_average.desc"
	case releaseDateDesc = "primary_release_date.desc"
	case releaseDateAsc = "primary_release_date.asc"
	
	var localizedString: LocalizedStringKey {
		switch self {
		case .popularity:
			return LocalizedStringKey("Popularity")
		case .rating:
			return LocalizedStringKey("Rating")
		case .releaseDateDesc:
			return LocalizedStringKey("Release Date (Descending)")
		case .releaseDateAsc:
			return LocalizedStringKey("Release Date (Ascending)")
		}
	}
}
