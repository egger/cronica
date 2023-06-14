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
                if #available(watchOS 10, *) {
                    ToolbarItem(placement: .bottomBar) {
                        filterButton
                            .labelStyle(.iconOnly)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                            .opacity(showPicker ? 0 : 1)
                            .opacity(showSearch ? 0 : 1)
                    }
                } else {
                    ToolbarItem(placement: .primaryAction) {
                        filterButton
                    }
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
            .onChange(of: selectedList) { newValue in
                if let newValue {
                    selectedOrder = newValue
                }
            }
        }
    }
    
    private var filterButton: some View {
        Button {
            withAnimation { showPicker = true }
        } label: {
            Label("Sort List", systemImage: "line.3.horizontal.decrease")
        }
        .buttonStyle(.borderedProminent)
        .tint(.accentColor)
    }
    
    @ViewBuilder
    private var defaultList: some View {
        if !query.isEmpty {
            SearchView(query: $query)
        } else if items.isEmpty {
            EmptyListView()
        } else {
            DefaultListView(selectedOrder: $selectedList)
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

@available(iOS 17, *)
@available(macOS 14, *)
@available(watchOS 10, *)
#Preview {
    WatchlistView()
}
