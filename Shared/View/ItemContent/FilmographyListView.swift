//
//  FilmographyListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 13/07/22.
//

import SwiftUI

struct FilmographyListView: View {
    let filmography: [ItemContent]?
    @Binding var showConfirmation: Bool
    @StateObject private var settings = SettingsStore.shared
    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: DrawingConstants.posterColumns))
    ]
    private let cardColumns: [GridItem] = [
        GridItem(.adaptive(minimum: DrawingConstants.columns))
    ]
    var body: some View {
        if let filmography {
            if !filmography.isEmpty {
                VStack {
                    TitleView(title: "Filmography", subtitle: "", image: nil)
#if os(tvOS)
                    cardStyle
#else
                    switch settings.listsDisplayType {
                    case .standard: posterStyle
                    case .poster: posterStyle
                    case .card: cardStyle
                    }
#endif
                }
            }
        }
    }
    
    @ViewBuilder
    private var posterStyle: some View {
        if let filmography {
            LazyVGrid(columns: settings.isCompactUI ? DrawingConstants.compactPosterColumns : columns,
                      spacing: settings.isCompactUI ? 10 : 20) {
                ForEach(filmography) { item in
                    Poster(item: item, addedItemConfirmation: $showConfirmation)
                }
            }.padding(.all, settings.isCompactUI ? 10 : nil)
        }
    }
    
    @ViewBuilder
    private var cardStyle: some View {
        if let filmography {
            LazyVGrid(columns: cardColumns, spacing: 20) {
                ForEach(filmography) { item in
                    CardFrame(item: item, showConfirmation: $showConfirmation)
                        .buttonStyle(.plain)
                }
            }
        }
    }
}

struct FilmographyListView_Previews: PreviewProvider {
    static var previews: some View {
        FilmographyListView(filmography: ItemContent.examples, showConfirmation: .constant(false))
    }
}

private struct DrawingConstants {
#if os(macOS)
    static let posterColumns: CGFloat = 160
    static let columns: CGFloat = 240
#elseif os(tvOS)
    static let posterColumns: CGFloat = 260
    static let columns: CGFloat = 440
#else
    static let posterColumns: CGFloat = 160
    static let spacing: CGFloat = 20
    static let columns: CGFloat = UIDevice.isIPad ? 240 : 160
#endif
    static let compactPosterColumns = [GridItem(.adaptive(minimum: 80))]
    static let compactSpacing: CGFloat = 10
}
