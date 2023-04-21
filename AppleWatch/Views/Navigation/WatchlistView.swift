//
//  WatchlistView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 13/08/22.
//

import SwiftUI

struct WatchlistView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        animation: .default) private var items: FetchedResults<WatchlistItem>
    @AppStorage("selectedOrder") private var selectedOrder: DefaultListTypes = .released
    @State private var selectedList: DefaultListTypes?
    @State private var selectedCustomList: CustomList?
    @State private var query = ""
    @State private var showPicker = false
    @State private var showSearch = false
    var body: some View {
        NavigationStack {
            VStack {
                if selectedList != nil {
                    defaultList
                } else if selectedCustomList != nil {
                    customList
                } else {
                    EmptyListView()
                }
            }
            .navigationTitle("Watchlist")
            .disableAutocorrection(true)
            .searchable(text: $query)
            .task(id: query) {
                if query.isEmpty { return }
                if Task.isCancelled { return }
                showSearch = true
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showPicker = true
                    } label: {
                        Label("Sort List",
                              systemImage: "line.3.horizontal.decrease.circle.fill")
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                    .padding(.bottom)
                }
            }
            .navigationDestination(for: WatchlistItem.self) { item in
                ItemContentView(id: item.itemId,
                                title: item.itemTitle,
                                type: item.itemMedia,
                                image: item.itemImage)
            }
            .navigationDestination(for: ItemContent.self) { item in
                if item.media == .person {
                    PersonView(id: item.id, name: item.itemTitle)
                } else {
                    ItemContentView(id: item.id,
                                    title: item.itemTitle,
                                    type: item.itemContentMedia,
                                    image: item.cardImageMedium)
                }
            }
            .sheet(isPresented: $showPicker) {
                WatchlistSelectorView(showView: $showPicker,
                                      selectedList: $selectedList,
                                      selectedCustomList: $selectedCustomList)
            }
            .onAppear {
                if selectedList == nil && selectedCustomList == nil {
                    selectedList = selectedOrder
                }
            }
        }
    }
    
    @ViewBuilder
    private var defaultList: some View {
        if !query.isEmpty {
            SearchView(query: $query)
        } else if items.isEmpty {
            EmptyListView()
        } else {
            DefaultListView()
        }
    }
    
    @ViewBuilder
    private var customList: some View {
        if !query.isEmpty {
            SearchView(query: $query)
        } else if items.isEmpty {
            EmptyListView()
        } else {
            CustomListView(list: $selectedCustomList)
        }
    }
}

struct WatchlistView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistView()
    }
}

private struct CustomListView: View {
    @Binding var list: CustomList?
    var body: some View {
        if let list {
            List {
                Section {
                    ForEach(list.itemsArray) { item in
                        WatchlistItemRow(content: item)
                    }
                } header: {
                    Text(list.itemTitle)
                        .lineLimit(1)
                }
            }
        } else {
            EmptyListView()
        }
    }
}
