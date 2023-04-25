//
//  ExternalWatchlistManager.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 24/04/23.
//

import SwiftUI

/// This class handles with fetching and sync of lists on external services.
///
/// Only TMDb is accepted at the moment.
class ExternalWatchlistManager {
    static let shared = ExternalWatchlistManager()
    private let contentTypeHeader = "application/json;charset=utf-8"
    private let decoder = JSONDecoder()
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy,MM,dd"
        return formatter
    }()
    private var userAccessToken = String()
    private var userAccessId = String()
    private var userSessionId = String()
    
    @Published var watchlist = [ItemContent]()
    
    private init() {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(ExternalWatchlistManager.dateFormatter)
        populateAccess()
    }
    
    private func populateAccess() {
        let data = KeychainHelper.standard.read(service: "access-token", account: "cronicaTMDB-Sync")
        let IdData = KeychainHelper.standard.read(service: "access-id", account: "cronicaTMDB-Sync")
        let session = KeychainHelper.standard.read(service: "session-id", account: "cronicaTMDB-Sync")
        guard let data else { return }
        let accessToken = String(data: data, encoding: .utf8)
        guard let accessToken else { return }
        userAccessToken = accessToken
        guard let IdData else { return }
        let accessId = String(data: IdData, encoding: .utf8)
        guard let accessId else { return }
        userAccessId = accessId
        guard let session else { return }
        let sessionId = String(data: session, encoding: .utf8)
        guard let sessionId else { return }
        userSessionId = sessionId
    }
    
    // MARK: Fetch
    func fetchLists() async -> TMDBList? {
        do {
            let headers = [
                "content-type": contentTypeHeader,
                "authorization": "Bearer \(userAccessToken)"
            ]
            var request = URLRequest(url: URL(string: "https://api.themoviedb.org/4/account/\(userAccessId)/lists")!,
                                     cachePolicy: .useProtocolCachePolicy,
                                     timeoutInterval: 10.0)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let content =  try decoder.decode(TMDBList.self, from: data)
            return content
        } catch {
            if Task.isCancelled { return nil }
        }
        return nil
    }
    
    func fetchList(id: TMDBListResult.ID) async -> DetailedTMDBList? {
        do {
            let headers = [
                "content-type": contentTypeHeader,
                "authorization": "Bearer \(userAccessToken)"
            ]
            var request = URLRequest(url: URL(string: "https://api.themoviedb.org/4/list/\(id)")!,
                                     cachePolicy: .useProtocolCachePolicy,
                                     timeoutInterval: 10.0)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let content =  try decoder.decode(DetailedTMDBList.self, from: data)
            return content
        } catch {
            if Task.isCancelled { return nil }
        }
        return nil
    }
    
    func fetchWatchlist(type: MediaType) async -> TMDBWatchlist? {
        do {
            let headers = [
                "content-type": contentTypeHeader,
                "authorization": "Bearer \(userAccessToken)"
            ]
            var request = URLRequest(url: URL(string: "https://api.themoviedb.org/4/account/\(userAccessId)/\(type.rawValue)/watchlist")!,
                                     cachePolicy: .useProtocolCachePolicy,
                                     timeoutInterval: 10.0)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let content =  try decoder.decode(TMDBWatchlist.self, from: data)
            return content
        } catch {
            if Task.isCancelled { return nil }
            CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                  for: "")
        }
        return nil
    }
    
    func updateList(_ id: TMDBListResult.ID, with items: Data) async {
        do {
            let headers = [
                "authorization": "Bearer \(userAccessToken)",
                "content-type": contentTypeHeader
            ]
            guard let url = URL(string: "https://api.themoviedb.org/4/list/\(id)/items") else { return }
            var request = URLRequest(url: url,
                                     cachePolicy: .useProtocolCachePolicy,
                                     timeoutInterval: 10.0)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = headers
            request.httpBody = items
            
            let (_, _) = try await URLSession.shared.data(for: request)
        } catch {
            if Task.isCancelled { return  }
        }
    }
}
