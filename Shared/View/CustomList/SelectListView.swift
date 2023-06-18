//
//  SelectListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 10/02/23.
//

import SwiftUI

struct SelectListView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CustomList.title, ascending: true)],
        animation: .default)
    private var lists: FetchedResults<CustomList>
    @Binding var selectedList: CustomList?
    @Binding var navigationTitle: String
    @Binding var showListSelection: Bool
    @State private var showAllItems = true
    @State private var showDeleteConfirmation = true
#if os(iOS)
    @Environment(\.editMode) private var editMode
#elseif os(macOS)
    @State private var isCreateNewListPresented = false
#endif
    @State private var isEditing = false
    var body: some View {
        NavigationStack {
#if os(iOS) || os(tvOS)
            form
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        doneButton
                    }
                    ToolbarItem {
                        if !lists.isEmpty { newList }
                    }
                }
#else
            form
                .formStyle(.grouped)
                .toolbar {
                    if !isCreateNewListPresented {
                        ToolbarItem(placement: .automatic) {
                            if !lists.isEmpty { newList }
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        doneButton
                    }
                }
#endif
        }
    }
    
    private var form: some View {
        Form {
            Section {
                List {
                    // default list selector
                    DefaultListRow(selectedList: $selectedList)
                        .onTapGesture {
                            HapticManager.shared.selectionHaptic()
                            selectedList = nil
                            showListSelection.toggle()
                        }
                    // if empty, offers a more visual way to create new list
                    if lists.isEmpty { newList }
                    else  {
                        ForEach(lists) { item in
#if os(tvOS)
                            Button {
                                HapticManager.shared.selectionHaptic()
                                selectedList = item
                                showListSelection.toggle()
                            } label: {
                                ListRowItem(list: item, selectedList: $selectedList)
                            }
#else
                            ListRowItem(list: item, selectedList: $selectedList)
                                .onTapGesture {
                                    HapticManager.shared.selectionHaptic()
                                    selectedList = item
                                    showListSelection.toggle()
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        if selectedList == item { selectedList = nil }
                                        PersistenceController.shared.delete(item)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
#if os(macOS)
                                            .foregroundColor(.red)
#endif
                                    }
                                    .tint(.red)
                                }
#if os(iOS) || os(macOS)
                                .swipeActions(edge: .leading, allowsFullSwipe: SettingsStore.shared.allowFullSwipe) {
                                    NavigationLink {
#if os(iOS) || os(tvOS)
                                        EditCustomList(list: item, showListSelection: $showListSelection)
#elseif os(macOS)
                                        EditCustomList(isPresentingNewList: $isCreateNewListPresented, list: item, showListSelection: $showListSelection)
#endif
                                    } label: {
                                        Text("Edit")
                                    }
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: SettingsStore.shared.allowFullSwipe) {
                                    Button(role: .destructive) {
                                        if selectedList == item { selectedList = nil }
                                        PersistenceController.shared.delete(item)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
#if os(macOS)
                                            .foregroundColor(.red)
#endif
                                    }
                                    .tint(.red)
                                }
#endif
#endif
                        }.onDelete(perform: delete)
                    }
                }
            } header: {
                HStack {
                    Text("yourLists")
                    Spacer()
#if os(iOS)
                    if !lists.isEmpty { EditButton() }
#endif
                }
            }
        }
    }
    
    private var doneButton: some View {
        Button("Done") { showListSelection.toggle() }
    }
    
    private var newList: some View {
#if os(tvOS)
        EmptyView()
#else
        NavigationLink {
#if os(iOS) || os(tvOS)
            NewCustomListView(presentView: $showListSelection, newSelectedList: $selectedList)
#elseif os(macOS)
            NewCustomListView(isPresentingNewList: $isCreateNewListPresented, presentView: $showListSelection, newSelectedList: $selectedList)
#endif
        } label: {
            Label("newList", systemImage: "plus.rectangle.on.rectangle")
        }
#endif
    }
    
    private func delete(offsets: IndexSet) {
        withAnimation {
            offsets.map { lists[$0] }.forEach(PersistenceController.shared.delete)
        }
    }
}

enum CustomNavigationMac: String, Identifiable, CaseIterable {
    var id: String { rawValue }
    case newList
}
