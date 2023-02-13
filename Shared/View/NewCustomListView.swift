//
//  NewCustomListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 08/02/23.
//

import SwiftUI

struct NewCustomListView: View {
    @Binding var presentView: Bool
    @State private var title = ""
    @State private var note = ""
    @State private var showMessage = false
    @State private var shareList = false
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        animation: .default)
    private var items: FetchedResults<WatchlistItem>
    @State private var itemsToAdd = Set<WatchlistItem>()
    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    Section {
                        TextField("listName", text: $title)
                        TextField("listDescription", text: $note)
                    } header: {
                        Label("listBasicHeader", systemImage: "pencil")
                    }
                    
                    Section {
                        Toggle("shareList", isOn: $shareList)
                    } header: {
                        Label("listShareHeader", systemImage: "person.3")
                    } footer: {
                        Text("listShareFooter")
                    }
                    
                    Section {
                        List(items) { item in
                            HStack {
                                if itemsToAdd.contains(item) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(SettingsStore.shared.appTheme.color)
                                } else {
                                    Image(systemName: "circle")
                                }
                                Text(item.itemTitle)
                            }
                            .onTapGesture {
                                if itemsToAdd.contains(item) {
                                    itemsToAdd.remove(item)
                                } else {
                                    itemsToAdd.insert(item)
                                }
                                
                            }
                            
                        }
                    } header: {
                        Text("listAdvancedHeader")
                    }
                }
                .navigationTitle("newCustomListTitle")
                .toolbar {
                    Button("createList") {
                        save()
                        presentView = false
                    }
                    .disabled(title.isEmpty)
                }
                
                ConfirmationDialogView(showConfirmation: $showMessage,
                                       message: "newCustomListMessage",
                                       image: "checkmark.circle.fill")
            }
        }
    }
    
    private func save() {
        if title.isEmpty { return }
        let viewContext = PersistenceController.shared.container.viewContext
        let list = CustomList(context: viewContext)
        list.id = UUID()
        list.title = title
        list.creationDate = Date()
        list.updatedDate = Date()
        list.shared = shareList
        list.notes = note
        list.items = itemsToAdd as NSSet
        print(list as Any)
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                showMessage = true
            } catch {
                let message = ""
                CronicaTelemetry.shared.handleMessage(message, for: "NewCustomListView.save()")
            }
        }
        title = ""
        presentView = false
    }
}

struct NewCustomListView_Previews: PreviewProvider {
    @State private static var presentView = true
    static var previews: some View {
        NewCustomListView(presentView: $presentView)
    }
}

struct EditCustomList: View {
    var list: CustomList
    @State private var title = ""
    @State private var note = ""
    @State private var shareList = false
    @State private var hasUnsavedChanges = false
    @State private var disableSaveButton = true
    var body: some View {
        Form {
            Section {
                TextField("listName", text: $title)
                TextField("listDescription", text: $note)
            } header: {
                Label("listBasicHeader", systemImage: "pencil")
            }
            
            Section {
                Toggle("shareList", isOn: $shareList)
            } header: {
                Label("listShareHeader", systemImage: "person.3")
            } footer: {
                Text("listShareFooter")
            }
            
            Section {
                List {
                    
                    
                }
            }
        }
        .onAppear {
            title = list.itemTitle
            note = list.notes ?? ""
            shareList = list.shared
        }
        .onChange(of: title, perform: { newValue in
            if newValue != list.itemTitle {
                disableSaveButton = false
            }
            
        })
        .toolbar {
            Button("Save") {
                
            }
            .disabled(disableSaveButton)
        }
        .navigationTitle(list.itemTitle)
    }
}
