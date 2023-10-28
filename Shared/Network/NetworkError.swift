//
//  NetworkError.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 09/05/22.
//

import Foundation
import SwiftUI

enum NetworkError: Error, CustomNSError {
    case invalidResponse, invalidRequest, invalidEndpoint, decodingError
    case invalidApi, internalError, maintenanceApi, contentRemoved
    var localizedName: LocalizedStringKey {
        switch self {
        case .invalidResponse:
            return "Invalid Response"
        case .invalidRequest:
            return "Invalid Request"
        case .invalidEndpoint:
            return "Invalid Endpoint"
        case .decodingError:
            return "Error reading this title"
        case .invalidApi:
            return "Invalid API key: You must be granted a valid key."
        case .internalError:
            return "Internal error: Something went wrong, contact TMDB."
        case .maintenanceApi:
            return "The API is undergoing maintenance. Try again later."
        case .contentRemoved:
            return "This content has been removed from TMDB, you can delete it."
        }
    }
}
