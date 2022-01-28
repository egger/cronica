//
//  NetworkError.swift
//  Story
//
//  Created by Alexandre Madeira on 19/01/22.
//

import Foundation

enum NetworkError: Error, CustomNSError {
    case invalidResponse, invalidRequest, invalidEndpoint, decodingError
}
