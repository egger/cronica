//
//  ItemContentCollectionDetails.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 30/11/22.
//

import SwiftUI

struct ItemContentCollectionDetails: View {
    let title: String
    let items: [ItemContent]
    @State private var showConfirmation = false
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    LazyVGrid(columns: DrawingConstants.columns, spacing: 20) {
                        ForEach(items) { item in
#if os(macOS)
                            Poster(item: item, addedItemConfirmation: $showConfirmation)
                                .buttonStyle(.plain)
#else
                            CardFrame(item: item, showConfirmation: $showConfirmation)
                                .buttonStyle(.plain)
#endif
                        }
                    }
                    .padding()
                    .navigationTitle(LocalizedStringKey(title))
                    AttributionView()
                }
            }
            ConfirmationDialogView(showConfirmation: $showConfirmation, message: "addedToWatchlist")
        }
    }
}

struct ItemContentCollectionDetails_Previews: PreviewProvider {
    static var previews: some View {
        ItemContentCollectionDetails(title: "Preview Items",
                                     items: ItemContent.previewContents)
    }
}

private struct DrawingConstants {
#if os(macOS)
    static let columns = [GridItem(.adaptive(minimum: 160))]
#else
    static let columns: [GridItem] = [GridItem(.adaptive(minimum: UIDevice.isIPad ? 240 : 160 ))]
#endif
}
