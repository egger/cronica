//
//  TrailerListView.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 05/04/22.
//

import SwiftUI

#if os(iOS) || os(macOS)
struct TrailerListView: View {
    var trailers: [VideoItem]
    @State private var hasLoaded = false
    var body: some View {
        if !trailers.isEmpty {
            VStack {
                TitleView(title: "Trailers")
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(trailers) { trailer in
                            TrailerItemView(trailer: trailer)
                                .padding(.horizontal, 4)
                                .padding(.leading, trailer.id == self.trailers.first?.id ? 16 : 0)
                                .padding(.trailing, trailer.id == self.trailers.last?.id ? 16 : 0)
                                .padding(.top, 8)
                        }
                    }
                }
            }
        }
    }
}
#endif
