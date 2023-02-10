//
//  SelectListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 10/02/23.
//

import SwiftUI

struct SelectListView: View {
    @Environment(\.managedObjectContext) var customListViewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CustomList.title, ascending: true)],
        animation: .default)
    private var lists: FetchedResults<CustomList>
    @Binding var selectedList: CustomList?
    @Binding var navigationTitle: String
    @Binding var showListSelection: Bool
    @State private var showAllItems = true
    @State private var showDeleteConfirmation = true
    @Environment(\.editMode) private var editMode
    @State private var isEditing = false
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    List {
                        HStack {
                            if selectedList == nil {
                                Image(systemName: "checkmark.circle.fill")
                                    .appTint()
                            } else {
                                Image(systemName: "circle")
                            }
                            VStack(alignment: .leading) {
                                Text("Watchlist")
                                Text("Default List")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .onTapGesture {
                            selectedList = nil
                            showListSelection.toggle()
                        }
                        if lists.isEmpty {
                            newList
                        } else {
                            ForEach(lists) { item in
                                ListRowItem(list: item, selectedList: $selectedList)
                                    .onTapGesture {
                                        selectedList = item
                                        showListSelection.toggle()
                                    }
                                    .swipeActions(edge: .leading,
                                                  allowsFullSwipe: SettingsStore.shared.allowFullSwipe) {
                                        Button {
                                            
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        .tint(SettingsStore.shared.appTheme.color)
                                    }
                                    .swipeActions(edge: .trailing,
                                                  allowsFullSwipe: SettingsStore.shared.allowFullSwipe) {
                                        Button(role: .destructive) {
                                            
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                        .tint(.red)
                                    }
                            }
                            .onDelete { _ in
                                
                            }
                        }
                    }
                } header: {
                    HStack {
                        Label("yourLists", systemImage: "rectangle.on.rectangle.angled")
                        Spacer()
                        if !lists.isEmpty { EditButton() }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        showListSelection.toggle()
                    }
                }
                ToolbarItem {
                    if !lists.isEmpty { newList }
                }
            }
        }
        .appTint()
        .appTheme()
        .onChange(of: editMode?.wrappedValue) { newValue in
            if let newValue {
                isEditing = newValue.isEditing
            } else {
                isEditing = false
            }
        }
    }
    
    private var defaultList: some View {
        HStack {
            if selectedList == nil {
                Image(systemName: "checkmark.circle.fill")
                    .appTint()
            } else {
                Image(systemName: "circle")
            }
            VStack(alignment: .leading) {
                Text("Watchlist")
                Text("Default List")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .disabled(isEditing)
    }
    
    private var newList: some View {
        NavigationLink {
            NewCustomListView(presentView: $showListSelection)
        } label: {
            Label("newList", systemImage: "plus.rectangle.on.rectangle")
        }
    }
}

//struct SelectListView_Previews: PreviewProvider {
//    static var previews: some View {
//        SelectListView()
//    }
//}

private struct ListRowItem: View {
    let list: CustomList
    @State private var isSelected = false
    @Binding var selectedList: CustomList?
    @Environment(\.editMode) private var editMode
    var body: some View {
        HStack {
            if editMode?.wrappedValue.isEditing ?? false {
                EmptyView()
            } else {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .appTint()
                } else {
                    Image(systemName: "circle")
                }
            }
            VStack(alignment: .leading) {
                Text(list.itemTitle)
                Text(list.itemGlanceInfo)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if list.shared {
                Image(systemName: "person.3")
                    .padding(.horizontal)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .onChange(of: selectedList) { _ in
            checkSelection()
        }
        .onAppear {
            checkSelection()
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
