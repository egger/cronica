//
//  HomeViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//

import Foundation
import CoreData
import TelemetryClient

@MainActor class HomeViewModel: ObservableObject {
    @Published private(set) var trendingPhase: DataFetchPhase<[Content]?> = .empty
    @Published private(set) var phase: DataFetchPhase<[ContentSection]?> = .empty
    private let service: NetworkService = NetworkService.shared
    var trendingSection: [Content]? {
        trendingPhase.value ?? nil
    }
    var sections: [ContentSection]? {
        phase.value ?? nil
    }
    
    func load() async {
        Task {
            if Task.isCancelled { return }
            if case .success = phase { return }
            phase = .empty
            do {
                var items: [ContentSection] = []
                let movies = try await self.fetchEndpoints()
                if Task.isCancelled { return }
                for movie in movies {
                    items.append(movie)
                }
                phase = .success(movies)
            } catch {
                if Task.isCancelled { return }
                phase = .failure(error)
            }
            if case .success = trendingPhase { return }
            trendingPhase = .empty
            do {
                let trendingContent = try await self.service.fetchContents(from: "trending/all/week")
                let trending = trendingContent.filter { $0.itemContentMedia != .person }
                trendingPhase = .success(trending)
            } catch {
                if Task.isCancelled { return }
                trendingPhase = .failure(error)
            }
        }
    }
    
    private func fetchEndpoints(_ endpoint: [Endpoints] = Endpoints.allCases) async throws -> [ContentSection] {
        let results: [Result<ContentSection, Error>] = await withTaskGroup(of: Result<ContentSection,
                                                                           Error>.self) { group in
            for endpoint in endpoint {
                group.addTask { await self.fetchFrom(endpoint, type: .movie) }
            }
            var results = [Result<ContentSection, Error>]()
            for await result in group {
                results.append(result)
            }
            return results
        }
        var sections = [ContentSection]()
        var errors = [Error]()
        
        results.forEach { result in
            switch result {
            case .success(let section):
                sections.append(section)
            case .failure(let error):
                TelemetryClient.TelemetryManager.send("endpointFailed", with: ["Error":"\(error.localizedDescription)"])
                errors.append(error)
            }
        }
        
        if errors.count == results.count,
           let error = errors.first {
            throw error
        }
        
        return sections.sorted { $0.endpoint.sortIndex < $1.endpoint.sortIndex }
    }
    
    private func fetchFrom(_ endpoint: Endpoints, type: MediaType) async -> Result<ContentSection, Error> {
        do {
            let section = try await service.fetchContents(from: "\(type.rawValue)/\(endpoint.rawValue)")
            return .success(.init(results: section, endpoint: endpoint))
        } catch {
            TelemetryManager.send("HomeViewModel_fetchFromError",
                                  with: ["Error:":"\(error.localizedDescription)"])
            return .failure(error)
        }
    }
}


//
////
////  HomeViewModel.swift
////  Story
////
////  Created by Alexandre Madeira on 02/03/22.
////
//
//import Foundation
//import CoreData
//import TelemetryClient
//
//@MainActor class HomeViewModel: ObservableObject {
//    @Published private(set) var phase: DataFetchPhase<[ContentSection]?> = .empty
//    private let service: NetworkService = NetworkService.shared
//    var trending: [Content]?
//    var section: [ContentSection]?
//
//    func load() async {
//        Task {
//
//            if trending == nil {
//                if Task.isCancelled { return }
//                do {
//                    trending = try await self.service.fetchContents(from: "trending/all/week")
//                    trending?.removeAll(where: { $0.itemContentMedia == .person } )
//                    print(trending as Any)
//                } catch {
//                    TelemetryClient.TelemetryManager.send("fetchTrendingError",
//                                                          with: ["Error":"\(error.localizedDescription)."])
//                }
//            }
//            if section == nil {
//                if Task.isCancelled { return }
//                do {
//                    let endpoints: [Endpoints] = Endpoints.allCases
//                    for endpoint in endpoints {
//                        let item = await self.fetchFrom(endpoint, type: .movie)
//                        if let item = item {
//                            section?.append(item)
//                        }
//                    }
////                    let movies = try await self.fetchEndpoints(type: .movie)
////                    for movie in movies {
////                        section?.append(movie)
////                        print(movie as Any)
////                    }
//                } catch {
//                    TelemetryClient.TelemetryManager.send("fetchSectionsError",
//                                                          with: ["Error":"\(error.localizedDescription)."])
//                }
//            }
//        }
//    }
//
//    private func fetchEndpoints(_ endpoint: [Endpoints] = Endpoints.allCases,
//                                type: MediaType) async throws -> [ContentSection] {
//        var items: [ContentSection] = []
//        for endpoint in endpoint {
//            let section = await self.fetchFrom(endpoint, type: type)
//            print("Hum")
//            if let section = section {
//                items.append(section)
//            }
//        }
////        Task {
////            for endpoint in endpoint {
////                await self.fetchFrom(endpoint, type: type)
////            }
////        }
//        return items.sorted { $0.endpoint.sortIndex < $1.endpoint.sortIndex }
//    }
//
//    private func fetchFrom(_ endpoint: Endpoints, type: MediaType) async -> ContentSection? {
//        do {
//            let section = try await service.fetchContents(from: "\(type.rawValue)/\(endpoint.rawValue)")
//            return ContentSection.init(results: section, endpoint: endpoint)
//            //return ContentSection.init(results: se, endpoint: <#T##Endpoints#>)
//            //return .success(.init(results: section, endpoint: endpoint))
//        } catch {
//            TelemetryManager.send("HomeViewModel_fetchFromError",
//                                  with: ["Error:":"\(error.localizedDescription)"])
//            //return .failure(error)
//        }
//        return nil
//    }
//}


//var sections: [ContentSection]? {
//    phase.value ?? nil
//}
//if case .success = phase { return }
//phase = .empty
//do {
//    var items: [ContentSection] = []
//    let movies = try await self.fetchEndpoints(type: .movie)
//    let shows = try await self.fetchEndpoints(type: .tvShow)
//    if Task.isCancelled { return }
//    for movie in movies {
//        items.append(movie)
//    }
//    for show in shows {
//        items.append(show)
//    }
//    phase = .success(movies)
//} catch {
//    if Task.isCancelled { return }
//    phase = .failure(error)
//}


//let results: [Result<ContentSection, Error>] = await withTaskGroup(of: Result<ContentSection,
//                                                                   Error>.self) { group in
//    for endpoint in endpoint {
//        if type == .movie && endpoint != Endpoints.onTheAir {
//            group.addTask { await self.fetchFrom(endpoint, type: type) }
//        }
//        else if type == .tvShow && endpoint == Endpoints.onTheAir {
//            group.addTask { await self.fetchFrom(endpoint, type: type) }
//        }
//    }
//    var results = [Result<ContentSection, Error>]()
//    for await result in group {
//        results.append(result)
//    }
//    return results
//}
//var sections = [ContentSection]()
//var errors = [Error]()
//
//results.forEach { result in
//    switch result {
//    case .success(let section):
//        sections.append(section)
//    case .failure(let error):
//        TelemetryClient.TelemetryManager.send("endpointFailed", with: ["Error":"\(error.localizedDescription)"])
//        errors.append(error)
//    }
//}
//
//if errors.count == results.count,
//   let error = errors.first {
//    throw error
//}
//
//return sections.sorted { $0.endpoint.sortIndex < $1.endpoint.sortIndex }
