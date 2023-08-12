//
//  TrendingView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 07/08/23.
//

import SwiftUI

struct TrendingView: View {
    static let tag: Screens? = .trending
    private let service: NetworkService = NetworkService.shared
    @State private var trending = [ItemContent]()
    @State private var isLoaded = false
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    List {
                        ForEach(trending) { item in
                            NavigationLink(value: item) {
								ItemContentRow(item: item)
                            }
                        }
                    }
                    .redacted(reason: isLoaded ? [] : .placeholder)
                }
            }
			.overlay { if !isLoaded { ProgressView().unredacted() } }
            .navigationTitle("Trending")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: ItemContent.self) { item in
				ItemContentView(id: item.id,
								title: item.itemTitle,
								type: item.itemContentMedia,
								image: item.cardImageMedium)
            }
            .onAppear(perform: load)
        }
    }
    
    private func load() {
        Task {
            if !isLoaded {
                if trending.isEmpty {
                    do {
                        let result = try await service.fetchItems(from: "trending/all/day")
                        let filtered = result.filter { $0.itemContentMedia != .person }
                        trending = filtered
                        isLoaded = true
                    } catch {
                        if Task.isCancelled { return }
                        let message = "Can't load trending/all/day, error: \(error.localizedDescription)"
                        CronicaTelemetry.shared.handleMessage(message, for: "TrendingView.load()")
                    }
                }
            }
        }
    }
}

struct TrendingView_Previews: PreviewProvider {
    static var previews: some View {
        TrendingView()
    }
}
