//
//  TrailerUtilities.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 29/07/22.
//

import Foundation

struct TrailerUtilities {
    static func fetch(for videos: [VideosResult]? = nil) -> [VideoItem]? {
        guard let videos else { return nil }
        var items: [VideoItem] = []
        for video in videos {
            if video.isTrailer {
                items.append(VideoItem.init(url: urlBuilder(video: video.key),
                                             thumbnail: fetchThumbnail(for: video.key),
                                             title: video.name))
            }
        }
        return items
    }
    
    /// Build a URL for the trailer, only generate YouTube links.
    /// - Parameter path: The 'key' for the trailer.
    /// - Returns: Returns nil if the path is nil, otherwise return a safe URL.
    private static func urlBuilder(video path: String? = nil) -> URL? {
        guard let path else { return nil }
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.youtube.com"
        components.path = "/embed/\(path)"
        return components.url
    }
    
    private static func fetchThumbnail(for id: String?) -> URL? {
        guard let id else { return nil }
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "img.youtube.com"
        urlComponents.path = "/vi/\(id)/maxresdefault.jpg"
        return urlComponents.url
    }
}
