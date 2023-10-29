//
//  ListRowItem.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 07/05/23.
//

import SwiftUI

struct ListRowItem: View {
    let list: CustomList
    @State private var isSelected = false
    @Binding var selectedList: CustomList?
#if os(iOS)
    @Environment(\.editMode) private var editMode
#endif
    var body: some View {
        HStack {
#if os(macOS)
            checkStage
#elseif os(iOS)
            if editMode?.wrappedValue.isEditing ?? false {
                EmptyView()
            } else {
                checkStage
            }
#endif
            VStack(alignment: .leading) {
                Text(list.itemTitle)
                    .font(.callout)
                Text(list.itemGlanceInfo)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(.leading, 4)
            Spacer()
        }
        .onChange(of: selectedList, checkSelection)
        .onAppear(perform: checkSelection)
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private var checkStage: some View {
        if isSelected {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(SettingsStore.shared.appTheme.color)
        } else {
            Image(systemName: "circle")
        }
    }
}

extension ListRowItem {
    private func checkSelection() {
        if let selectedList {
            if selectedList == list {
                isSelected = true
            } else {
                isSelected = false
            }
        } else {
            isSelected = false
        }
    }
}
