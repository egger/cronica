//
//  NetworkError.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 09/05/22.
//

import Foundation

enum NetworkError: Error, CustomNSError {
    case invalidResponse, invalidRequest, invalidEndpoint, decodingError
}
