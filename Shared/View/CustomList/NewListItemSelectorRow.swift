//
//  NewListItemSelectorRow.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 03/05/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct NewListItemSelectorRow: View {
    let item: WatchlistItem
    @State private var isSelected = false
    @Binding var selectedItems: Set<WatchlistItem>
    var body: some View {
        Button {
            if selectedItems.contains(item) {
                selectedItems.remove(item)
                withAnimation { isSelected = false }
                HapticManager.shared.selectionHaptic()
            } else {
                selectedItems.insert(item)
                withAnimation { isSelected = true }
                HapticManager.shared.selectionHaptic()
            }
        } label: {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? SettingsStore.shared.appTheme.color : nil)
                    .imageScale(.medium)
                    .padding(.trailing, 4)
                WebImage(url: item.image)
                    .resizable()
                    .placeholder {
                        ZStack {
                            Rectangle().fill(.gray.gradient)
                            Image(systemName: "popcorn.fill")
                        }
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 70, height: 50)
                    .cornerRadius(8)
                    .overlay {
                        if isSelected {
                            ZStack {
                                Rectangle().fill(.black.opacity(0.4))
                            }
                            .cornerRadius(8)
                        }
                    }
                    .padding(.trailing, 4)
                VStack(alignment: .leading) {
                    Text(item.itemTitle)
                        .lineLimit(1)
                        .foregroundColor(isSelected ? .secondary : nil)
                    Text(item.itemMedia.title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
        .task {
            if !isSelected && selectedItems.contains(item) {
                withAnimation { isSelected = true }
            }
        }
    }
}

struct NewListItemSelectorRow_Previews: PreviewProvider {
    static var previews: some View {
        NewListItemSelectorRow(item: .example, selectedItems: .constant(Set<WatchlistItem>()))
    }
}
