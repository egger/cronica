//
//  WatchlistSectionView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 13/08/22.
//

import SwiftUI

struct WatchlistSectionView: View {
    let items: [WatchlistItem]
    let title: String
    var body: some View {
        if !items.isEmpty {
            Section {
                ForEach(items) { item in
                    WatchlistItemView(content: item)
                }
            } header: {
                Text(NSLocalizedString(title, comment: ""))
            }
            .padding(.bottom)
        }
    }
}

struct WatchlistSectionView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistSectionView(items: [WatchlistItem.example],
                             title: "Preview")
    }
}
