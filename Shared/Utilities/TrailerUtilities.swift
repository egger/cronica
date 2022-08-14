//
//  TrailerUtilities.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 29/07/22.
//

import Foundation

struct TrailerUtilities {
    static func fetch(for videos: [VideosResult]? = nil) -> [VideoItem]? {
        if let videos {
            var items: [VideoItem] = []
            for video in videos {
                if video.official && video.type.lowercased() == "trailer" {
                    items.append(VideoItem.init(url: urlBuilder(video: video.key),
                                                 thumbnail: fetchThumbnail(for: video.key),
                                                 title: video.name))
                }
            }
            if !items.isEmpty {
                return items
            }
        }
        return nil
    }
    
    /// Build a URL for the trailer, only generate YouTube links.
    /// - Parameter path: The 'key' for the trailer.
    /// - Returns: Returns nil if the path is nil, otherwise return a safe URL.
    private static func urlBuilder(video path: String? = nil) -> URL? {
        if let path {
            var components = URLComponents()
            components.scheme = "https"
            components.host = "www.youtube.com"
            components.path = "/embed/\(path)"
            return components.url
        }
        return nil
    }
    
    private static func fetchThumbnail(for id: String?) -> URL? {
        if let id {
            var urlComponents = URLComponents()
            urlComponents.scheme = "https"
            urlComponents.host = "img.youtube.com"
            urlComponents.path = "/vi/\(id)/maxresdefault.jpg"
            return urlComponents.url
        }
        return nil
    }
}
