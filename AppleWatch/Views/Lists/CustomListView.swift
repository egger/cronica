//
//  CustomListView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 22/04/23.
//

import SwiftUI

struct CustomListView: View {
    @Binding var list: CustomList?
    var body: some View {
        if let list {
            List {
                Section {
                    ForEach(list.itemsArray) { item in
                        WatchlistItemRow(content: item)
                    }
                } header: {
                    Text(list.itemTitle)
                        .lineLimit(1)
                }
            }
        } else {
            EmptyListView()
        }
    }
}
