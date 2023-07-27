//
//  EditCustomList.swift
//  Story
//
//  Created by Alexandre Madeira on 18/02/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct EditCustomList: View {
#if os(macOS)
    @Binding var isPresentingNewList: Bool
#endif
    @State var list: CustomList
    @State private var title = String()
    @State private var note = String()
    @State private var hasUnsavedChanges = false
    @State private var disableSaveButton = true
    @Binding var showListSelection: Bool
    @State private var itemsToRemove = Set<WatchlistItem>()
    @State private var showPublishConfirmation = false
    @State private var canPublish = false
    @State private var isPublishing = false
    @State private var pinOnHome = false
    @State private var askConfirmationForDeletion = false
    @State private var isDeleted = false
    @State private var itemsToAdd = Set<WatchlistItem>()
    var body: some View {
        Form {
            if isDeleted {
                Text("This list has been deleted.")
                    .font(.title3)
                    .foregroundColor(.secondary)
            } else {
                Section {
                    TextField("listName", text: $title)
                    TextField("listDescription", text: $note)
                }
                
                Section {
                    Toggle("pinOnHome", isOn: $pinOnHome)
                }
                
                NavigationLink("listItemsToAdd",
                               destination: NewCustomListItemSelector(itemsToAdd: $itemsToAdd, list: list))
                
                if !list.itemsSet.isEmpty {
                    NavigationLink("editListRemoveItems", destination: EditCustomListItemSelector(list: list, itemsToRemove: $itemsToRemove))
                }
                
                Section {
                    Button(role: .destructive) {
                        askConfirmationForDeletion = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .foregroundColor(.red)
                }
                .alert("removeDialogTitle", isPresented: $askConfirmationForDeletion) {
                    Button("Confirm", role: .destructive) {
                        isDeleted = true
                        PersistenceController.shared.delete(list)
                    }
                    Button("confirmAndDeleteItems", role: .destructive) {
                        isDeleted = true
                        let itemsToDelete = list.itemsArray
                        PersistenceController.shared.delete(list)
                        for item in itemsToDelete {
                            PersistenceController.shared.delete(item)
                        }
                    }
                }
                
            }
        }
#if os(macOS)
        .formStyle(.grouped)
#endif
        .onAppear {
            title = list.itemTitle
            note = list.notes ?? ""
            pinOnHome = list.isPin
            if SettingsStore.shared.isUserConnectedWithTMDb && !list.isSyncEnabledTMDB {
                canPublish = true
            }
        }
        .onChange(of: title) { newValue in
            if newValue != list.itemTitle {
                disableSaveButton = false
            }
        }
        .onChange(of: itemsToAdd) { _ in
            disableSaveButton = false
        }
        .onChange(of: note) { newValue in
            if newValue != list.notes {
                disableSaveButton = false
            }
        }
        .onChange(of: pinOnHome) { newValue in
            if newValue != list.isPin { disableSaveButton = false }
        }
        .onChange(of: itemsToRemove) { _ in
            if !itemsToRemove.isEmpty {
                if disableSaveButton != false { disableSaveButton = false }
            }
        }
        .onAppear {
#if os(macOS)
            isPresentingNewList = true
#endif
        }
        .onDisappear {
#if os(macOS)
            isPresentingNewList = false
#endif
        }
        .toolbar {
            Button("Save", action: save).disabled(disableSaveButton)
        }
        .navigationTitle(list.itemTitle)
    }
    
    private func save() {
        let persistence = PersistenceController.shared
        if list.title != title {
            persistence.updateListTitle(of: list, with: title)
        }
        if list.notes != note {
            persistence.updateListNotes(of: list, with: note)
        }
        if !itemsToRemove.isEmpty {
            persistence.removeItemsFromList(of: list, with: itemsToRemove)
        }
        if list.isPin != pinOnHome {
            persistence.updatePinOnHome(of: list)
        }
        if !itemsToAdd.isEmpty {
            persistence.addItemsToList(items: itemsToAdd, list: list)
        }
        showListSelection = false
    }
}

struct EditCustomListItemSelector: View {
    var list: CustomList
    @Binding var itemsToRemove: Set<WatchlistItem>
    @State private var query = String()
    @State private var searchItems = [WatchlistItem]()
    var body: some View {
        Form {
            if !searchItems.isEmpty {
                Section {
                    List {
                        ForEach(searchItems) { item in
                            HStack {
                                Image(systemName: itemsToRemove.contains(item) ? "minus.circle.fill" : "circle")
                                    .foregroundColor(itemsToRemove.contains(item) ? .red : nil)
                                WebImage(url: item.image)
                                    .resizable()
                                    .placeholder {
                                        ZStack {
                                            Rectangle().fill(.gray.gradient)
                                            Image(systemName: item.itemMedia == .movie ? "film" : "tv")
                                        }
                                    }
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 70, height: 50)
                                    .cornerRadius(8)
                                    .overlay {
                                        if itemsToRemove.contains(item) {
                                            ZStack {
                                                Rectangle().fill(.black.opacity(0.4))
                                            }
                                            .cornerRadius(8)
                                        }
                                    }
                                VStack(alignment: .leading) {
                                    Text(item.itemTitle)
                                        .lineLimit(1)
                                        .foregroundColor(itemsToRemove.contains(item) ? .secondary : nil)
                                    Text(item.itemMedia.title)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .onTapGesture {
                                if itemsToRemove.contains(item) {
                                    itemsToRemove.remove(item)
                                } else {
                                    itemsToRemove.insert(item)
                                }
                            }
                        }
                    }
                }
            } else {
                Section {
                    List {
                        ForEach(list.itemsArray, id: \.itemContentID) { item in
                            HStack {
                                Image(systemName: itemsToRemove.contains(item) ? "minus.circle.fill" : "circle")
                                    .foregroundColor(itemsToRemove.contains(item) ? .red : nil)
                                WebImage(url: item.image)
                                    .resizable()
                                    .placeholder {
                                        ZStack {
                                            Rectangle().fill(.gray.gradient)
                                            Image(systemName: item.itemMedia == .movie ? "film" : "tv")
                                        }
                                    }
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 70, height: 50)
                                    .cornerRadius(8)
                                    .overlay {
                                        if itemsToRemove.contains(item) {
                                            ZStack {
                                                Rectangle().fill(.black.opacity(0.4))
                                            }
                                            .cornerRadius(8)
                                        }
                                    }
                                VStack(alignment: .leading) {
                                    Text(item.itemTitle)
                                        .lineLimit(1)
                                        .foregroundColor(itemsToRemove.contains(item) ? .secondary : nil)
                                    Text(item.itemMedia.title)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .onTapGesture {
                                if itemsToRemove.contains(item) {
                                    itemsToRemove.remove(item)
                                } else {
                                    itemsToRemove.insert(item)
                                }
                            }
                        }
                    }
                }
            }
            
        }
        .overlay { if list.itemsArray.isEmpty { Text("Empty") } }
        .task(id: query) {
            await search()
        }
        .navigationTitle("editListRemoveItems")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
#else
        .searchable(text: $query)
#endif
        .formStyle(.grouped)
    }
    
    private func search() async {
        try? await Task.sleep(nanoseconds: 300_000_000)
        if query.isEmpty && !searchItems.isEmpty { searchItems = [] }
        if query.isEmpty { return }
        if !searchItems.isEmpty { searchItems.removeAll() }
        searchItems.append(contentsOf: list.itemsArray.filter {
            ($0.itemTitle.localizedStandardContains(query)) as Bool
            || ($0.itemOriginalTitle.localizedStandardContains(query)) as Bool
        })
    }
}
