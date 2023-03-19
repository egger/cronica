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
#if os(iOS)
            form
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        doneButton
                    }
                    ToolbarItem {
                        if !lists.isEmpty { newList }
                    }
                }
#elseif os(macOS)
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
                            .buttonStyle(.link)
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
                            selectedList = nil
                            showListSelection.toggle()
                        }
                    // if empty, offers a more visual way to create new list
                    if lists.isEmpty { newList }
                    else  {
                        ForEach(lists) { item in
                            ListRowItem(list: item, selectedList: $selectedList)
                                .onTapGesture {
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
                                .swipeActions(edge: .leading, allowsFullSwipe: SettingsStore.shared.allowFullSwipe) {
                                    NavigationLink {
#if os(iOS)
                                        EditCustomList(list: item, showListSelection: $showListSelection)
#else
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
        Button("Done") {
            showListSelection.toggle()
        }
    }
    
    private var newList: some View {
        NavigationLink {
#if os(iOS)
            NewCustomListView(presentView: $showListSelection, newSelectedList: $selectedList)
#else
            NewCustomListView(isPresentingNewList: $isCreateNewListPresented, presentView: $showListSelection)
#endif
        } label: {
            Label("newList", systemImage: "plus.rectangle.on.rectangle")
        }
#if os(macOS)
        .buttonStyle(.link)
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

//struct SelectListView_Previews: PreviewProvider {
//    static var previews: some View {
//        SelectListView()
//    }
//}

private struct DefaultListRow: View {
    @Binding var selectedList: CustomList?
#if os(iOS)
    @Environment(\.editMode) private var editMode
#endif
    var body: some View {
        HStack {
#if os(macOS)
            checkStage
#else
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

private struct ListRowItem: View {
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
#else
            if editMode?.wrappedValue.isEditing ?? false {
                EmptyView()
            } else {
                checkStage
            }
#endif
            VStack(alignment: .leading) {
                Text(list.itemTitle)
                Text(list.itemGlanceInfo)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            Spacer()
        }
        .onChange(of: selectedList) { _ in
            checkSelection()
        }
        .onAppear {
            checkSelection()
        }
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
