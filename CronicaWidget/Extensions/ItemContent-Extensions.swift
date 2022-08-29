//
//  ItemContent-Extensions.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 26/08/22.
//

import Foundation

extension ItemContent {
    var cardImage: URL? {
        return NetworkService.urlBuilder(size: .medium, path: backdropPath)
    }
    var posterImage: URL? {
        return NetworkService.urlBuilder(size: .small, path: posterPath)
    }
    var itemTitle: String {
        title ?? name!
    }
    var itemMedia: MediaType {
        if title != nil { return .movie }
        return .tvShow
    }
    var itemUrlId: String {
        return "\(itemMedia.toInt)\(id)"
    }
    static let placeholder = ItemContent(id: 639933, title: "The Northman", name: nil, posterPath: "/8p9zXB7M78nZpm215zHfqpknMeM.jpg", backdropPath: "/cIjmEgK67974md4Z9Xe6350sAS2.jpg", data: nil)
    static var previewContents: [ItemContent] {
        let data: ItemContentResponse? = try? Bundle.main.decode(from: "DataPlaceholder")
        if let results = data?.results {
            var items = [ItemContent]()
            for item in results {
                var imagePath = String()
                switch item.id {
                case 72844: imagePath = "2"
                case 530915: imagePath = "3"
                case 137113: imagePath = "4"
                default: imagePath = "1"
                }
                let itemContent = ItemContent(id: item.id,
                                              title: item.title,
                                              name: item.name,
                                              posterPath: item.posterPath,
                                              backdropPath: item.backdropPath,
                                              data: nil,
                                              placeholderImagePath: imagePath)
                items.append(itemContent)
            }
            if !items.isEmpty {
                return items
            }
        }
        return data!.results
    }
}
