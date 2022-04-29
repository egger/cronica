//
//  ImageSize.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 28/04/22.
//

import Foundation

enum ImageSize: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case small = "t/p/w154"
    case medium = "t/p/w500"
    case large = "t/p/w1066_and_h600_bestv2"
    case original = "t/p/original"
}
