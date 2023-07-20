//
//  WatchlistSectionView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 21/04/23.
//

import SwiftUI

struct WatchlistSectionView: View {
    let items: [WatchlistItem]
    let title: String
    @State private var showPopup = false
    @State private var popupType: ActionPopupItems?
    var body: some View {
        if !items.isEmpty {
            Section {
                ForEach(items) { item in
                    WatchlistItemRow(content: item, showPopup: $showPopup, popupType: $popupType)
                }
            } header: {
                Text(NSLocalizedString(title, comment: ""))
            }
            .padding(.bottom)
        } else {
            Text("No results")
        }
    }
}

struct WatchlistSectionView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistSectionView(items: [.example], title: "SwiftUI Preview")
    }
}
