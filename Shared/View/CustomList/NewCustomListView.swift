//
//  NewCustomListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 08/02/23.
//

import SwiftUI
import SDWebImageSwiftUI

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
        animation: .default)
    private var items: FetchedResults<WatchlistItem>
    @State private var itemsToAdd = Set<WatchlistItem>()
    // This allows the SelectedListView to change to the new list when it is created.
    @Binding var newSelectedList: CustomList?
    var body: some View {
        Form {
            Section {
                TextField("listName", text: $title)
                TextField("listDescription", text: $note)
            } header: {
                Text("listBasicHeader")
            }
            
            if !items.isEmpty {
                Section {
                    List(items, id: \.notificationID) { item in
                        HStack {
                            Image(systemName: itemsToAdd.contains(item) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(itemsToAdd.contains(item) ? SettingsStore.shared.appTheme.color : nil)
                                .padding(.trailing, 4)
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
                            // do not remove the withAnimation, it works.
                            if itemsToAdd.contains(item) {
                                itemsToAdd.remove(item)
                            } else {
                                itemsToAdd.insert(item)
                            }
                        }
                    }
                } header: {
                    Text("listItemsToAdd")
                }
                .onAppear {
                    if let preSelectedItem {
                        itemsToAdd.insert(preSelectedItem)
                    }
                }
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
        .navigationTitle("newCustomListTitle")
        .toolbar {
#if os(macOS)
            ToolbarItem(placement: .automatic) {
                createList
                    .buttonStyle(.link)
            }
            ToolbarItem(placement: .cancellationAction) {
                cancelButton
                    .buttonStyle(.link)
            }
#else
            createList
#endif
        }
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
    
    private var createList: some View {
        Button("createList") {
            save()
            presentView = false
        }
        .disabled(title.isEmpty)
    }
    
    private var cancelButton: some View {
        Button("Cancel") { presentView = false }
    }
    
    private func save() {
        if title.isEmpty { return }
        let viewContext = PersistenceController.shared.container.viewContext
        let list = CustomList(context: viewContext)
        list.id = UUID()
        list.title = title
        list.creationDate = Date()
        list.updatedDate = Date()
        list.notes = note
        list.items = itemsToAdd as NSSet
        print(list as Any)
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                HapticManager.shared.successHaptic()
                newSelectedList = list
            } catch {
                CronicaTelemetry.shared.handleMessage(error.localizedDescription, for: "NewCustomListView.save()")
            }
        }
        title = ""
#if os(iOS)
        presentView = false
#endif
    }
}

struct NewCustomListView_Previews: PreviewProvider {
    @State private static var presentView = true
    @State private static var list: CustomList? = nil
    static var previews: some View {
#if os(iOS)
        NewCustomListView(presentView: $presentView, newSelectedList: $list)
#else
        EmptyView()
#endif
    }
}
