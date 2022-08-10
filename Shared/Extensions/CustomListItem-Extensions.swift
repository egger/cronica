//
//  CustomListItem-Extensions.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 09/08/22.
//

import Foundation

extension CustomListItem {
    var itemTitle: String {
        title ?? NSLocalizedString("No Title Found", comment: "")
    }
}
