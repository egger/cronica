//
//  Credits-Extensions.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 28/04/22.
//

import Foundation

extension Credits {
    static var previewCredits: Credits {
        return ItemContent.previewContent.credits!
    }
    static var previewCast: Person {
        return previewCredits.cast[2]
    }
    static var previewCrew: Person {
        return previewCredits.crew[0]
    }
}
