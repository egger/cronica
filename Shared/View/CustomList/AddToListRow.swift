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
               .padding(.horizontal)
           VStack(alignment: .leading) {
               Text(list.itemTitle)
               Text(list.itemGlanceInfo)
                   .foregroundColor(.secondary)
                   .font(.caption)
           }
       }
       .onTapGesture {
           guard let item else { return }
           PersistenceController.shared.updateList(for: item.notificationID, to: list)
           HapticManager.shared.successHaptic()
           withAnimation { isItemAdded.toggle() }
           showView.toggle()
       }
       .onAppear { isItemInList() }
   }
   
   private func isItemInList() {
       if let item {
           if list.itemsSet.contains(item) { isItemAdded.toggle() }
       }
   }
}
