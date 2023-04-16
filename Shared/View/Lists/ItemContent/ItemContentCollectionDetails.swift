//
//  ItemContentCollectionDetails.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 30/11/22.
//

import SwiftUI
#if os(iOS) || os(macOS)
struct ItemContentCollectionDetails: View {
    let title: String
    let items: [ItemContent]
    @State private var showConfirmation = false
    @State private var settings = SettingsStore.shared
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    if settings.listsDisplayType == .poster {
                        posterStyle
                    } else {
                        cardStyle
                    }
                    AttributionView()
                }
                .navigationTitle(LocalizedStringKey(title))
            }
            ConfirmationDialogView(showConfirmation: $showConfirmation, message: "addedToWatchlist")
        }
    }
    
    @ViewBuilder
    private var cardStyle: some View {
        LazyVGrid(columns: DrawingConstants.columns, spacing: 20) {
            ForEach(items) { item in
                CardFrame(item: item, showConfirmation: $showConfirmation)
                    .buttonStyle(.plain)
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private var posterStyle: some View {
        LazyVGrid(columns: settings.isCompactUI ? DrawingConstants.compactColumns : DrawingConstants.columns,
                  spacing: settings.isCompactUI ? 10 : 20) {
            ForEach(items) { item in
                Poster(item: item, addedItemConfirmation: $showConfirmation)
                    .buttonStyle(.plain)
            }
        }
        .padding(.all, settings.isCompactUI ? 10 : nil)
    }
}

struct ItemContentCollectionDetails_Previews: PreviewProvider {
    static var previews: some View {
        ItemContentCollectionDetails(title: "Preview Items",
                                     items: ItemContent.previewContents)
    }
}

private struct DrawingConstants {
#if os(macOS) || os(tvOS)
    static let columns = [GridItem(.adaptive(minimum: 160))]
#else
    static let columns: [GridItem] = [GridItem(.adaptive(minimum: UIDevice.isIPad ? 240 : 160 ))]
    static let compactColumns: [GridItem] = [GridItem(.adaptive(minimum: 80))]
#endif
}
#endif
