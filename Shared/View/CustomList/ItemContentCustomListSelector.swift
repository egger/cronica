//
//  ItemContentCustomListSelector.swift
//  Story
//
//  Created by Alexandre Madeira on 21/03/23.
//

import SwiftUI

struct ItemContentCustomListSelector: View {
    @Binding var item: WatchlistItem?
    @Binding var showView: Bool
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CustomList.title, ascending: true)],
        animation: .default)
    private var lists: FetchedResults<CustomList>
    @State private var selectedList: CustomList?
    var body: some View {
        NavigationStack {
            Form {
                if item != nil {
                    Section {
                        List {
                            if lists.isEmpty { List { newList } }
                            ForEach(lists) { list in
                                AddToListRow(list: list, item: $item, showView: $showView)
                            }
                        }
                    } header: { Text("yourLists") }
                } else {
                    ProgressView()
                }
            }
#if os(macOS)
            .formStyle(.grouped)
#endif
            .navigationTitle("addToCustomList")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { showView.toggle() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !lists.isEmpty { newList }
                }
#elseif os(macOS)
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { showView.toggle() }
                }
                ToolbarItem(placement: .automatic) {
                    if !lists.isEmpty { newList }
                }
#elseif os(watchOS)
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { showView.toggle() }
                }
                ToolbarItem(placement: .automatic) {
                    if !lists.isEmpty { newList }
                }
#endif
            }
        }
    }
    
    private var newList: some View {
        NavigationLink {
#if os(iOS) || os(tvOS) || os(watchOS)
            NewCustomListView(presentView: $showView, preSelectedItem: item, newSelectedList: $selectedList)
#elseif os(macOS)
            NewCustomListView(isPresentingNewList: $showView,
                              presentView: $showView,
                              preSelectedItem: item,
                              newSelectedList: $selectedList)
#endif
        } label: {
            Label("newList", systemImage: "plus.rectangle.on.rectangle")
        }
    }
}

private struct AddToListRow: View {
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
