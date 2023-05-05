//
//  CustomListButton.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 04/05/23.
//

import SwiftUI

struct CustomListButton: View {
    let id: String
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \CustomList.title, ascending: true)],
                  animation: .default) private var lists: FetchedResults<CustomList>
    @State private var addedLists = [CustomList]()
    private let context = PersistenceController.shared
    var body: some View {
        if !lists.isEmpty {
#if os(iOS) || os(macOS) || os(watchOS)
            Menu {
                ForEach(lists) { list in
                    Button {
                        context.updateList(for: id, to: list)
                        addedLists.append(list)
                    } label: {
                        if addedLists.contains(list) {
                            HStack {
#if os(iOS)
                                Image(systemName: "checkmark")
#endif
                                Text(list.itemTitle)
#if os(macOS)
                                Image(systemName: "checkmark")
#endif
                            }
                        } else {
                            Text(list.itemTitle)
                        }
                    }
                    
                }
            } label: {
                Label("addToList", systemImage: "rectangle.on.rectangle.angled")
            }
            .onAppear {
                if addedLists.isEmpty {
                    addedLists = context.fetchLists(for: id)
                }
            }
#endif
        } else {
            EmptyView()
        }
    }
}

struct CustomListButton_Previews: PreviewProvider {
    static var previews: some View {
        CustomListButton(id: ItemContent.example.itemNotificationID)
    }
}
