//
//  SeriesViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 28/01/22.
//

import Foundation

@MainActor
class SeriesViewModel: ObservableObject {
    @Published private(set) var phase: DataFetchPhase<[SeriesSection]> = .empty
    private let service: NetworkService = NetworkService.shared
    var sections: [SeriesSection] {
        phase.value ?? []
    }
}
