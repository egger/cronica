//
//  DefaultListRow.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 07/05/23.
//

import SwiftUI

struct DefaultListRow: View {
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
                Text("Watchlist")
                Text("Default List")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var checkStage: some View {
        if selectedList == nil {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(SettingsStore.shared.appTheme.color)
        } else {
            Image(systemName: "circle")
        }
    }
}
