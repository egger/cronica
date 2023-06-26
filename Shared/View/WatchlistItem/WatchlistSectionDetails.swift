//
//  WatchlistSectionDetails.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 28/01/23.
//

import SwiftUI
#if os(iOS) || os(macOS)
struct WatchlistSectionDetails: View {
    var title = "Upcoming"
    let items: [WatchlistItem]
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: DrawingConstants.columns, spacing: 20) {
                    ForEach(items) { item in
                        WatchlistItemFrame(content: item)
                            .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(LocalizedStringKey(title))
    }
}

private struct DrawingConstants {
#if os(macOS)
    static let columns = [GridItem(.adaptive(minimum: 240))]
#else
    static let columns = [GridItem(.adaptive(minimum: UIDevice.isIPad ? 240 : 160))]
#endif
}

struct WatchlistSectionDetails_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistSectionDetails(items: [.example])
    }
}
#endif
