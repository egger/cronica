//
//  PersonItem-Extensions.swift
//  Story
//
//  Created by Alexandre Madeira on 05/08/22.
//

import Foundation

extension PersonItem {
    var personName: String {
        name ?? NSLocalizedString("No Name Found", comment: "")
    }
    var type: MediaType {
        return .person
    }
    var example: PersonItem {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        let item = PersonItem(context: viewContext)
        item.name = Credits.previewCast.name
        item.id = Int64(Credits.previewCast.id)
        item.image = Credits.previewCast.personImage
        return item
    }
}
