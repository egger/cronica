//
//  NewCustomListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 08/02/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct NewCustomListView: View {
    @Binding var presentView: Bool
    @State private var title = ""
    @State private var note = ""
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
                        List(items, id: \.notificationID) { item in
                            HStack {
                                Image(systemName: itemsToAdd.contains(item) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(itemsToAdd.contains(item) ? SettingsStore.shared.appTheme.color : nil)
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
                                        if itemsToAdd.contains(item) {
                                            ZStack {
                                                Rectangle().fill(.black.opacity(0.4))
                                            }
                                            .cornerRadius(6)
                                        }
                                    }
                                VStack(alignment: .leading) {
                                    Text(item.itemTitle)
                                        .lineLimit(1)
                                        .foregroundColor(itemsToAdd.contains(item) ? .secondary : nil)
                                    Text(item.itemMedia.title)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
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
                        Label("listItemsToAdd", systemImage: "rectangle.on.rectangle")
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
        list.shared = false
        list.notes = note
        list.items = itemsToAdd as NSSet
        print(list as Any)
        if viewContext.hasChanges {
            do {
                try viewContext.save()
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
    @State var list: CustomList
    @State private var title = ""
    @State private var note = ""
    @State private var shareList = false
    @State private var hasUnsavedChanges = false
    @State private var disableSaveButton = true
    @Binding var showListSelection: Bool
    var body: some View {
        Form {
            Section {
                TextField("listName", text: $title)
                TextField("listDescription", text: $note)
            } header: {
                Label("listBasicHeader", systemImage: "pencil")
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
        .onChange(of: note, perform: { newValue in
            if newValue != list.notes {
                disableSaveButton = false
            }
        })
        .toolbar {
            Button("Save") {
                PersistenceController.shared.updateListInformation(list: list,
                                                                   title: title,
                                                                   description: note)
                showListSelection = false
            }
            .disabled(disableSaveButton)
        }
        .navigationTitle(list.itemTitle)
    }
}
