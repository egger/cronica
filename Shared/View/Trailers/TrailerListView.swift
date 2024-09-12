//
//  TrailerListView.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 05/04/22.
//

import SwiftUI

struct TrailerListView: View {
    var trailers: [VideoItem]
    @State private var hasLoaded = false
    var body: some View {
        if !trailers.isEmpty {
            VStack {
                TitleView(title: String(localized: "Trailers"))
#if os(tvOS)
                    .padding(.horizontal, 64)
#endif
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(trailers) { trailer in
                            TrailerItemView(trailer: trailer)
                                .padding(.horizontal, 4)
#if !os(tvOS)
                                .padding(.leading, trailer.id == self.trailers.first?.id ? 16 : 0)
                                .padding(.trailing, trailer.id == self.trailers.last?.id ? 16 : 0)
#else
                                .padding(.leading, trailer.id == self.trailers.first?.id ? 64 : 0)
                                .padding(.trailing, trailer.id == self.trailers.last?.id ? 64 : 0)
#endif
                                .padding(.top, 8)
                                .accessibilityIdentifier("\(trailer.title)")
                        }
                    }
                }
            }
            .accessibilityIdentifier("Trailers List")
        }
    }
}
