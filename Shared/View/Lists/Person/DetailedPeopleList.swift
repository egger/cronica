//
//  DetailedPeopleList.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 21/01/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct DetailedPeopleList: View {
    let items: [Person]
    @State private var query = ""
    @State private var filteredItems = [Person]()
    var body: some View {
        VStack {
            if query.isEmpty {
#if os(iOS)
                List {
                    ForEach(items, id: \.personListID) { item in
                        PersonItemRow(person: item)
                    }
                }
#else
                Table(items) {
                    TableColumn("Person") { item in
                        PersonItemRow(person: item)
                            .buttonStyle(.plain)
                            .accessibilityHint(Text(item.name))
                    }
                }
#endif
            } else {
                if !query.isEmpty && filteredItems.isEmpty {
                    Text("No Results")
                        .font(.headline)
                        .foregroundColor(.secondary)
                } else {
#if os(iOS)
                    List {
                        ForEach(filteredItems, id: \.personListID) { item in
                            PersonItemRow(person: item)
                        }
                    }
#else
                    Table(filteredItems) {
                        TableColumn("Person") { item in
                            PersonItemRow(person: item)
                                .buttonStyle(.plain)
                                .accessibilityHint(Text(item.name))
                        }
                    }
#endif
                }
            }
        }
        .navigationTitle("Cast & Crew")
        .task(id: query) {
            if query.isEmpty {
                return
            } else if query.isEmpty && !filteredItems.isEmpty {
                filteredItems = []
            } else {
                if !filteredItems.isEmpty {
                    withAnimation {
                        filteredItems = []
                    }
                }
                let results = items.filter { $0.name.lowercased().contains(query.lowercased())}
                withAnimation {
                    filteredItems = results
                }
            }
        }
#if os(iOS)
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
        .autocorrectionDisabled()
#else
        .searchable(text: $query)
#endif
    }
}

struct DetailedPeopleList_Previews: PreviewProvider {
    static var previews: some View {
        DetailedPeopleList(items: ItemContent.previewContent.credits?.cast ?? [])
    }
}

private struct PersonItemRow: View {
    let person: Person
    var body: some View {
        NavigationLink(value: person) {
            HStack {
                WebImage(url: person.personImage)
                    .resizable()
                    .placeholder {
                        ZStack {
                            Rectangle().fill(.gray.gradient)
                            Image(systemName: "person")
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .frame(width: 60, height: 60, alignment: .center)
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60)
                    .clipShape(Circle())
                    .shadow(radius: 2)
                    .padding(.trailing)
                VStack(alignment: .leading) {
                    Text(person.name)
                        .lineLimit(1)
                    if let role = person.personRole {
                        Text(role)
                            .lineLimit(1)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 70)
            .contextMenu {
                ShareLink(item: person.itemURL)
            }
        }
        .buttonStyle(.plain)
        .draggable(person)
    }
}
