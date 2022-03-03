//
//  Preview.swift
//  Story
//
//  Created by Alexandre Madeira on 17/01/22.
//

import Foundation

extension Content {
    static var previewContents: [Content] {
        let data: ContentResponse? = try? Bundle.main.decode(from: "movies")
        return data!.results
    }
    static var previewContent: Content {
        previewContents[0]
    }
}
extension Credits {
    static var previewCredits: Credits {
        return Content.previewContent.credits!
    }
    static var previewCast: Person {
        return previewCredits.cast[2]
    }
    static var previewCrew: Person {
        return previewCredits.crew[0]
    }
}
