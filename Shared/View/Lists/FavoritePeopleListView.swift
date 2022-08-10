//
//  FavoritePeopleListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 10/08/22.
//

import SwiftUI

struct FavoritePeopleListView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PersonItem.name, ascending: true)],
        animation: .default)
    private var items: FetchedResults<PersonItem>
    private var filteredItems: [PersonItem] {
        return items.filter { ($0.name?.localizedStandardContains(query))! as Bool }
    }
    @State private var query = ""
    var body: some View {
        VStack {
            if !items.isEmpty {
                List {
                    if !filteredItems.isEmpty {
                        FavoritePeopleStructView(items: filteredItems, title: "Filtered Results")
                    } else if !query.isEmpty && filteredItems.isEmpty {
                        Text("No results found.")
                    } else {
                        FavoritePeopleStructView(items: items.filter { $0.type == .person }, title: "\(items.count) people")
                    }
                }
                .listStyle(.insetGrouped)
            } else {
                Text("Your list is empty.")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .navigationTitle("Favorite People")
        .navigationDestination(for: PersonItem.self) { item in
            PersonDetailsView(title: item.personName, id: Int(item.id))
        }
        .navigationDestination(for: ItemContent.self) { item in
            ItemContentView(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
        }
        .navigationDestination(for: Person.self) { person in
            PersonDetailsView(title: person.name, id: person.id)
        }
        .toolbar {
            EditButton()
        }
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
        .disableAutocorrection(true)
    }
    
   
}

struct FavoritePeopleListView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritePeopleListView()
    }
}

private struct FavoritePeopleStructView: View {
    let items: [PersonItem]
    let title: String
    private let context = PersistenceController.shared
    var body: some View {
        Section {
            ForEach(items) { item in
                PersonItemView(item: item)
                    .contextMenu {
                        ShareLink(item: item.itemUrl)
                        Divider()
                        Button(role: .destructive, action: {
                            withAnimation {
                                deleteItem(item: item)
                            }
                        }, label: {
                            Label("Remove", systemImage: "trash")
                        })
                    }
            }
            .onDelete(perform: delete)
        } header: {
            Text(NSLocalizedString(title, comment: ""))
        }
    }
    
    private func delete(offsets: IndexSet) {
        HapticManager.shared.mediumHaptic()
        withAnimation {
            offsets.map { items[$0] }.forEach(context.delete)
        }
    }
    
    private func deleteItem(item: PersonItem) {
        HapticManager.shared.mediumHaptic()
        withAnimation {
            context.delete(item)
        }
    }
}
