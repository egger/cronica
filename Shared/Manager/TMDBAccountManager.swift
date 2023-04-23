//
//  TMDBAccountManager.swift
//  Story
//
//  Created by Alexandre Madeira on 21/04/23.
//

import Foundation

class TMDBAccountManager {
    static let shared = TMDBAccountManager()
    private let contentTypeHeader = "application/json;charset=utf-8"
    private let decoder = JSONDecoder()
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy,MM,dd"
        return formatter
    }()
    private var requestToken = String()
    private var userAccessToken = String()
    private var userAccessId = String()
    
    private init() {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(TMDBAccountManager.dateFormatter)
    }
    
    func checkAccessStatus() -> Bool {
        let data = KeychainHelper.standard.read(service: "access-token", account: "cronicaTMDB-Sync")
        let IdData = KeychainHelper.standard.read(service: "access-id", account: "cronicaTMDB-Sync")
        guard let data, let IdData else { return false }
        let accessToken = String(data: data, encoding: .utf8)
        let accessId = String(data: IdData, encoding: .utf8)
        guard let accessToken, let accessId else { return false }
        userAccessToken = accessToken
        userAccessId = accessId
        return true
    }
    
    func requestToken() async -> URL? {
        do {
            guard let authorizationHeader = Key.authorizationHeader else { return nil }
            // Fetch and get the request token
            let headers = [
                "content-type": contentTypeHeader,
                "authorization": authorizationHeader
            ]
            let parameters = ["redirect_to": "cronica://"]
            
            let postData = try JSONSerialization.data(withJSONObject: parameters)
            
            var request = URLRequest(url: URL(string: "https://api.themoviedb.org/4/auth/request_token")!,
                                     cachePolicy: .useProtocolCachePolicy,
                                     timeoutInterval: 10.0)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = headers
            request.httpBody = postData
            let (data, _) = try await URLSession.shared.data(for: request)
            let content =  try decoder.decode(RequestTokenTMDB.self, from: data)
            guard let token = content.requestToken else { return nil }
            self.requestToken = token
            
            // Build and return the URL with the request token
            let url = URL(string: "https://www.themoviedb.org/auth/access?request_token=\(token)")
            return url
        } catch {
            if Task.isCancelled { return nil }
            CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                  for: "")
            return nil
        }
    }
    
    func requestAccess() async {
        guard let authorizationHeader = Key.authorizationHeader else { return }
        do {
            let headers = [
                "content-type": contentTypeHeader,
                "authorization": authorizationHeader
            ]
            let parameters = ["request_token": "\(self.requestToken)"]
            let postData = try JSONSerialization.data(withJSONObject: parameters)
            var request = URLRequest(url: URL(string: "https://api.themoviedb.org/4/auth/access_token")!,
                                     cachePolicy: .useProtocolCachePolicy,
                                     timeoutInterval: 10.0)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = headers
            request.httpBody = postData
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let content =  try decoder.decode(AccessTokenTMDB.self, from: data)
            saveUserAccess(for: content)
        } catch {
            if Task.isCancelled { return }
            CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                  for: "")
        }
    }
    
    private func saveUserAccess(for user: AccessTokenTMDB) {
        guard let token = user.accessToken else { return }
        guard let id = user.accountId else { return }
        let accessToken = Data(token.utf8)
        let accessId = Data(id.utf8)
        KeychainHelper.standard.save(accessToken, service: "access-token", account: "cronicaTMDB-Sync")
        KeychainHelper.standard.save(accessId, service: "access-id", account: "cronicaTMDB-Sync")
    }
    
    func removeUserAccess() {
        KeychainHelper.standard.delete(service: "access-token", account: "cronicaTMDB-Sync")
        KeychainHelper.standard.delete(service: "access-id", account: "cronicaTMDB-Sync")
    }
    
    func fetchLists() async -> TMDBList? {
        if userAccessToken.isEmpty || userAccessId.isEmpty {
            _ = checkAccessStatus()
        }
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
            CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                  for: "")
        }
        return nil
    }
    
    func fetchList(id: TMDBListResult.ID) async -> DetailedTMDBList? {
        if userAccessToken.isEmpty || userAccessId.isEmpty {
            _ = checkAccessStatus()
        }
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
            CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                  for: "")
        }
        return nil
    }
    
    func fetchWatchlist(type: MediaType) async -> TMDBWatchlist? {
        if userAccessToken.isEmpty || userAccessId.isEmpty {
            _ = checkAccessStatus()
        }
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
    
    
}
