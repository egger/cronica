//
//  CustomList+CoreDataClass.swift
//  Cronica
//
//  Created by Alexandre Madeira on 11/03/23.
//
//

import Foundation
import CoreData

@objc(CustomList)
public class CustomList: NSManagedObject, Codable {
    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else {
            throw ContextError.NoContextFound
        }
        self.init(context: context)
        
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            creationDate = try values.decode(Date.self, forKey: .creationDate)
            id = try values.decode(UUID.self, forKey: .id)
            notes = try values.decode(String.self, forKey: .notes)
            title = try values.decode(String.self, forKey: .title)
            updatedDate = try values.decode(Date.self, forKey: .updatedDate)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(creationDate, forKey: .creationDate)
        try values.encode(id, forKey: .id)
        try values.encode(notes, forKey: .notes)
        try values.encode(title, forKey: .title)
        try values.encode(updatedDate, forKey: .updatedDate)
    }
    
    enum CodingKeys: CodingKey {
        case creationDate, id, notes, title, updatedDate, items
    }
}
