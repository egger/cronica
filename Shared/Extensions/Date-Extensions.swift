//
//  Date-Extensions.swift
//  Story
//
//  Created by Alexandre Madeira on 04/11/22.
//

import Foundation

extension Date {
    func convertDateToString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
}
