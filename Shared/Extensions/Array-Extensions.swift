//
//  Array-Extensions.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 12/05/22.
//

import Foundation

extension Array: EmptyData {}
extension Optional: EmptyData {
    var isEmpty: Bool {
        if case .none = self {
            return true
        }
        return false
    }
}
