//
//  NewCustomListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 08/02/23.
//

import SwiftUI

struct NewCustomListView: View {
#if os(macOS)
    @Binding var isPresentingNewList: Bool
#endif
    @Binding var presentView: Bool
    var preSelectedItem: WatchlistItem?
    @State private var title = ""
    @State private var note = ""
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        animation: .default) private var items: FetchedResults<WatchlistItem>
    @State private var itemsToAdd = Set<WatchlistItem>()
    // This allows the SelectedListView to change to the new list when it is created.
    @Binding var newSelectedList: CustomList?
    @State private var searchQuery = String()
    @State private var publishOnTMDB = false
    @State private var pinOnHome = false
    var body: some View {
        Form {
            Section("listBasicHeader") {
                TextField("listName", text: $title)
                TextField("listDescription", text: $note)
                if SettingsStore.shared.connectedTMDB {
                    Toggle("publishOnTMDB", isOn: $publishOnTMDB)
                }
                Toggle("pinOnHome", isOn: $pinOnHome)
            }
            
            if !items.isEmpty {
                Section("listItemsToAdd") {
                    List(items, id: \.notificationID) {
                        NewListItemSelectorRow(item: $0, selectedItems: $itemsToAdd)
                    }
                }
                .onAppear {
                    if let preSelectedItem {
                        itemsToAdd.insert(preSelectedItem)
                    }
                }
            }
        }
#if os(macOS)
        .onAppear { isPresentingNewList = true }
        .onDisappear { isPresentingNewList = false }
#endif
        .navigationTitle("newCustomListTitle")
        .toolbar {
#if os(macOS)
            ToolbarItem(placement: .automatic) { createList }
            ToolbarItem(placement: .cancellationAction) { cancelButton }
#else
            createList
#endif
        }
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
    
    private var createList: some View {
        Button("createList", action: save).disabled(title.isEmpty)
    }
    
    private var cancelButton: some View {
        Button("Cancel") { presentView = false }
    }
    
    private func save() {
        if title.isEmpty { return }
        if publishOnTMDB {
            Task {
                let idOnTMDb = await handlePublish()
                handleSave(idOnTMDb: idOnTMDb)
            }
        } else {
            handleSave(idOnTMDb: nil)
        }
    }
    
    private func handleSave(idOnTMDb: Int?) {
        let list = PersistenceController.shared.createList(title: title,
                                                           description: note,
                                                           items: itemsToAdd,
                                                           idOnTMDb: idOnTMDb,
                                                           isPin: pinOnHome)
        HapticManager.shared.successHaptic()
        newSelectedList = list
        title = ""
        presentView = false
    }
    
    private func handlePublish() async -> Int? {
        let external = ExternalWatchlistManager.shared
        let id = await external.publishList(title: title, description: note, isPublic: false)
        guard let id else { return nil }
        
        // Gets the items to update the list
        var itemsToAdd = [TMDBItemContent]()
        for item in self.itemsToAdd {
            let content = TMDBItemContent(media_type: item.itemMedia.rawValue, media_id: item.itemId)
            itemsToAdd.append(content)
        }
        let itemsToPublish = TMDBItem(items: itemsToAdd)
        
        // Encode the items and update the new list
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys]
            let jsonData = try encoder.encode(itemsToPublish)
            await external.updateList(id, with: jsonData)
            return id
        } catch {
            if Task.isCancelled { return nil }
        }
        return nil
    }
}

struct NewCustomListView_Previews: PreviewProvider {
    static var previews: some View {
#if os(iOS) || os(watchOS) || os(tvOS)
        NewCustomListView(presentView: .constant(true), newSelectedList: .constant(nil))
#elseif os(macOS)
        NewCustomListView(isPresentingNewList: .constant(false),
                          presentView: .constant(true),
                          newSelectedList: .constant(nil))
#endif
    }
}
