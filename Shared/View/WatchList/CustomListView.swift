//
//  CustomListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 09/08/22.
//

import SwiftUI

struct CustomListView: View {
    let list: CustomListItem
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        animation: .default)
    private var items: FetchedResults<WatchlistItem>
    var body: some View {
        VStack {
            List {
                ForEach(items.filter { $0.list == list }) { item in
                    ItemView(content: item)
                }
            }
        }
        .navigationTitle(list.itemTitle)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    
                }, label: {
                    Label("Delete List", systemImage: "trash")
                })
            }
        }
    }
}

//struct CustomListView_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomListView()
//    }
//}
