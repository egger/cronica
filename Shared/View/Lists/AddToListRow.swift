//
//  AddToListRow.swift
//  Cronica
//
//  Created by Alexandre Madeira on 07/05/23.
//

import SwiftUI

struct AddToListRow: View {
    @State private var isItemAdded = false
    var list: CustomList
    @Binding var item: WatchlistItem?
    @Binding var showView: Bool
    var body: some View {
        HStack {
            Image(systemName: isItemAdded ? "checkmark.circle.fill" : "circle")
                .foregroundColor(SettingsStore.shared.appTheme.color)
                .padding(.leading, 4)
            VStack(alignment: .leading) {
                Text(list.itemTitle)
                Text(list.itemGlanceInfo)
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.leading, 4)
        }
        .onTapGesture {
            guard let item else { return }
            PersistenceController.shared.updateList(for: item.itemContentID, to: list)
            HapticManager.shared.selectionHaptic()
            withAnimation { isItemAdded.toggle() }
        }
        .onAppear { isItemInList() }
    }
    
    private func isItemInList() {
        if let item {
            if list.itemsSet.contains(item) { isItemAdded.toggle() }
        }
    }
}
