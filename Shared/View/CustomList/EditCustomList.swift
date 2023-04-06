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
    @State private var title = ""
    @State private var note = ""
    @State private var hasUnsavedChanges = false
    @State private var disableSaveButton = true
    @Binding var showListSelection: Bool
    @State private var itemsToRemove = Set<WatchlistItem>()
    var body: some View {
        Form {
            Section {
                TextField("listName", text: $title)
                TextField("listDescription", text: $note)
            } header: {
                Text("listBasicHeader")
            }
            
            Section {
                if !list.itemsArray.isEmpty {
                    List {
                        ForEach(list.itemsArray, id: \.notificationID) { item in
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
        .onChange(of: itemsToRemove, perform: { _ in
            if !itemsToRemove.isEmpty {
                if disableSaveButton != false { disableSaveButton = false }
            }
        })
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
            Button("Save") {
                let items = itemsToRemove.sorted { $0.itemTitle > $1.itemTitle }
                PersistenceController.shared.updateListInformation(list: list,
                                                                   title: title,
                                                                   description: note,
                                                                   items: items)
                showListSelection = false
            }
            .disabled(disableSaveButton)
        }
        .navigationTitle(list.itemTitle)
    }
}
