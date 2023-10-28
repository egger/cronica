//
//  DisplayInformationPreference.swift
//  Cronica
//
//  Created by Alexandre Madeira on 11/08/23.
//

import Foundation

enum DisplayInformationPreference: String, Identifiable, CaseIterable {
	var id: String { rawValue }
	case upcoming, search, releaseDate, none
}
