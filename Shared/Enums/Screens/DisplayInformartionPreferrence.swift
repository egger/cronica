//
//  DisplayInformartionPreferrence.swift
//  Story
//
//  Created by Alexandre Madeira on 11/08/23.
//

import Foundation

enum DisplayInformartionPreferrence: String, Identifiable, CaseIterable {
	var id: String { rawValue }
	case upcoming, search, releaseDate, none
}
