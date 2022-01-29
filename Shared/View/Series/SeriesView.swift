//
//  SeriesView.swift
//  Story
//
//  Created by Alexandre Madeira on 20/01/22.
//

import SwiftUI

struct SeriesView: View {
    static let tag: String? = "Series"
    @StateObject private var viewModel = SeriesViewModel()
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ForEach(viewModel.sections) {
                        HorizontalSeriesListView(style: $0.style, title: $0.title, series: $0.result)
                    }
                }
                .task {
                    load()
                }
            }
            .navigationTitle("TV Shows")
        }
        .navigationViewStyle(.stack)
    }
    
    @Sendable
    func load() {
        Task {
            await self.viewModel.loadAllEndpoints()
        }
    }
}

struct TvView_Previews: PreviewProvider {
    static var previews: some View {
        SeriesView()
    }
}
