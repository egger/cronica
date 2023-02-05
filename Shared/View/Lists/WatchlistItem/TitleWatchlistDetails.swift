//
//  TitleWatchlistDetails.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 28/01/23.
//

import SwiftUI

struct TitleWatchlistDetails: View {
    var title = "Upcoming"
    let items: [WatchlistItem]
    var body: some View {
        VStack {
#if os(macOS)
            WatchListSection(items: items, title: title)
#else
            List(items) { item in
                WatchlistItemRow(content: item)
            }
            
#endif
        }
        .navigationTitle(LocalizedStringKey(title))
    }
}

struct TitleWatchlistDetails_Previews: PreviewProvider {
    static var previews: some View {
        TitleWatchlistDetails(items: [.example])
    }
}
