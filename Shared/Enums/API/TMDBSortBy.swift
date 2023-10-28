//
//  TMDBSortBy.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 27/01/23.
//

import SwiftUI

enum TMDBSortBy: String, Identifiable, CaseIterable {
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
