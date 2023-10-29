//
//  SearchStage.swift
//  Story
//
//  Created by Alexandre Madeira on 29/10/23.
//

import Foundation

enum SearchStage: String {
    var id: String { rawValue }
    case none, failure, empty, success, searching
}
