//
//  AddToListRow.swift
//  Story
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

struct TMDBAddToListRow: View {
    @State private var isItemAdded = false
    var list: TMDBListResult
    var item: WatchlistItem?
    @Binding var showView: Bool
    @EnvironmentObject var viewModel: ExternalWatchlistManager
    var body: some View {
        HStack {
            Image(systemName: isItemAdded ? "checkmark.circle.fill" : "circle")
                .foregroundColor(SettingsStore.shared.appTheme.color)
                .padding(.leading, 4)
            VStack(alignment: .leading) {
                Text(list.itemTitle)
            }
            .padding(.leading, 4)
        }
        .onTapGesture {
            //guard let item else { return }
            
            HapticManager.shared.selectionHaptic()
            //withAnimation { isItemAdded.toggle() }
        }
        .onAppear { isItemInList() }
    }
    
    private func isItemInList() {
        if let item {
            Task {
                let isItemOnList = await viewModel.checkItemStatusOnList(list.id,
                                                                         itemID: item.itemId,
                                                                         itemMedia: item.itemMedia)
                print("is \(item.itemTitle) in list \(list.itemTitle)? \(isItemOnList.description)")
                await MainActor.run {
                    withAnimation { isItemAdded = isItemOnList }
                }
            }
        }
    }
}
