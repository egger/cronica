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
    @State private var queryString: String = ""
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ForEach(viewModel.sections) {
                        TvListView(style: $0.style, title: $0.title, series: $0.results)
                    }
                }
                .task {
                    load()
                }
            }
            .searchable(text: $queryString)
            .navigationTitle("TV Shows")
        }
        #if os(iOS)
        .navigationViewStyle(.stack)
        #endif
    }
    
    @Sendable
    private func load() {
        Task {
            await viewModel.loadAllEndpoints()
        }
    }
}

//struct TvView_Previews: PreviewProvider {
//    static var previews: some View {
//        SeriesView()
//    }
//}
