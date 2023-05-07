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
    var body: some View {
        Form {
            Section {
                TextField("listName", text: $title)
                TextField("listDescription", text: $note)
                Toggle("pinOnHome", isOn: $pinOnHome)
            } header: {
                Text("listBasicHeader")
            }
            
            if canPublish {
                Section {
                    Button {
                        showPublishConfirmation.toggle()
                    } label: {
                        if isPublishing {
                            CenterHorizontalView { ProgressView() }
                        } else {
                            Text("publishListToTMDB")
                        }
                    }
                }
                .alert("publishListToTMDB", isPresented: $showPublishConfirmation) {
                    Button("publishPublic") { publishToTMDB(isPublic: true) }
                    Button("publishPrivate") { publishToTMDB() }
                    Button("Cancel") { showPublishConfirmation = false }
                } message: {
                    Text("publishTMDBMessage")
                }
            }
            
            Section {
                if !list.itemsArray.isEmpty {
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
                                    .cornerRadius(6)
                                    .overlay {
                                        if itemsToRemove.contains(item) {
                                            ZStack {
                                                Rectangle().fill(.black.opacity(0.4))
                                            }
                                            .cornerRadius(6)
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
            } header: {
                Text("editListRemoveItems")
            }
        }
#if os(macOS)
        .formStyle(.grouped)
#endif
        .onAppear {
            title = list.itemTitle
            note = list.notes ?? ""
            pinOnHome = list.isPin
            if SettingsStore.shared.connectedTMDB && !list.isSyncEnabledTMDB {
                canPublish = true
            }
        }
        .onChange(of: title) { newValue in
            if newValue != list.itemTitle {
                disableSaveButton = false
            }
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
        showListSelection = false
    }
    
    private func publishToTMDB(isPublic: Bool = false) {
        Task {
            DispatchQueue.main.async {
                withAnimation { isPublishing.toggle() }
            }
            // Create and publish the new list
            let external = ExternalWatchlistManager.shared
            let title = list.itemTitle
            let description = list.notes ?? String()
            let id = await external.publishList(title: title, description: description, isPublic: isPublic)
            guard let id else { return }
            
            // Gets the items to update the list
            var itemsToAdd = [TMDBItemContent]()
            for item in list.itemsArray {
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
            } catch {
                if Task.isCancelled { return }
            }
            
            list.isSyncEnabledTMDB = true
            list.idOnTMDb = Int64(id)
            
            let context = PersistenceController.shared.container.viewContext
            if context.hasChanges {
                try? context.save()
            }
            
            DispatchQueue.main.async {
                withAnimation {
                    isPublishing.toggle()
                    canPublish.toggle()
                }
            }
        }
    }
}
