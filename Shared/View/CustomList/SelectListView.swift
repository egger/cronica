//
//  SelectListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 10/02/23.
//

import SwiftUI

/// This view is responsible for lettings users select which their want to see in WatchlistView.
struct SelectListView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CustomList.title, ascending: true)],
        animation: .default)
    private var lists: FetchedResults<CustomList>
    @Binding var selectedList: CustomList?
    @Binding var navigationTitle: String
    @Binding var showListSelection: Bool
    @State private var showAllItems = true
    @State private var showDeleteConfirmation = true
#if os(iOS)
    @Environment(\.editMode) private var editMode
#elseif os(macOS)
    @State private var isCreateNewListPresented = false
#endif
    @State private var isEditing = false
    // Lists
    @State private var listManager = ExternalWatchlistManager.shared
    @State private var tmdbLists = [TMDBListResult]()
    @State private var isLoading = true
    var body: some View {
        NavigationStack {
#if os(iOS) || os(tvOS)
            form
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        doneButton
                    }
                    ToolbarItem {
                        if !lists.isEmpty { newList }
                    }
                }
#else
            form
                .formStyle(.grouped)
                .toolbar {
                    if !isCreateNewListPresented {
                        ToolbarItem(placement: .automatic) {
                            if !lists.isEmpty { newList }
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        doneButton
                    }
                }
#endif
        }
    }
    
    private var form: some View {
        Form {
            Section {
                List {
                    // default list selector
                    DefaultListRow(selectedList: $selectedList)
                        .onTapGesture {
                            HapticManager.shared.selectionHaptic()
                            selectedList = nil
                            showListSelection.toggle()
                        }
                    // if empty, offers a more visual way to create new list
                    if lists.isEmpty { newList }
                    else  {
                        ForEach(lists) { item in
#if os(tvOS)
                            Button {
                                HapticManager.shared.selectionHaptic()
                                selectedList = item
                                showListSelection.toggle()
                            } label: {
                                ListRowItem(list: item, selectedList: $selectedList)
                            }
#else
                            ListRowItem(list: item, selectedList: $selectedList)
                                .onTapGesture {
                                    HapticManager.shared.selectionHaptic()
                                    selectedList = item
                                    showListSelection.toggle()
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        if selectedList == item { selectedList = nil }
                                        PersistenceController.shared.delete(item)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
#if os(macOS)
                                            .foregroundColor(.red)
#endif
                                    }
                                    .tint(.red)
                                }
#if os(iOS) || os(macOS)
                                .swipeActions(edge: .trailing, allowsFullSwipe: SettingsStore.shared.allowFullSwipe) {
                                    NavigationLink {
#if os(iOS) || os(tvOS)
                                        EditCustomList(list: item, showListSelection: $showListSelection)
#elseif os(macOS)
                                        EditCustomList(isPresentingNewList: $isCreateNewListPresented, list: item, showListSelection: $showListSelection)
#endif
                                    } label: {
                                        Text("Edit")
                                    }
                                }
#endif
#endif
                        }
                    }
                }
            } header: {
                HStack {
                    Text("yourLists")
                    Spacer()
                }
            } footer: {
                HStack {
                    Text("Swipe right to Edit your list")
                    Spacer()
                }
            }
            
            tmdbSection
        }
        .onAppear {
            if SettingsStore.shared.isUserConnectedWithTMDb {
                Task { await load() }
            }
        }
        .navigationDestination(for: ItemContent.self) { item in
            ItemContentDetails(title: item.itemTitle,
                               id: item.id,
                               type: item.itemContentMedia)
        }
        .navigationDestination(for: Person.self) { person in
            PersonDetailsView(title: person.name, id: person.id)
        }
        .navigationDestination(for: [String:[ItemContent]].self) { item in
            let keys = item.map { (key, _) in key }
            let value = item.map { (_, value) in value }
            ItemContentSectionDetails(title: keys[0], items: value[0])
        }
        .navigationDestination(for: [Person].self) { items in
            DetailedPeopleList(items: items)
        }
        .navigationDestination(for: ProductionCompany.self) { item in
            CompanyDetails(company: item)
        }
        .navigationDestination(for: [ProductionCompany].self) { item in
            CompaniesListView(companies: item)
        }
        .navigationDestination(for: TMDBListResult.self) { item in
            TMDBListDetails(list: item)
        }
    }
    
    @ViewBuilder
    private var tmdbSection: some View {
        if SettingsStore.shared.isUserConnectedWithTMDb {
            Section {
                List {
                    NavigationLink(destination: TMDBWatchlistView()) {
                        Text("Watchlist")
                    }
                    ForEach(tmdbLists) { list in
                        NavigationLink(value: list) {
                            Text(list.itemTitle)
                        }
                    }
                }
            } header: {
                HStack {
                    Text("TMDB")
                    Spacer()
                }
            }
            .redacted(reason: isLoading ? .placeholder : [])
        }
    }
    
    private func load() async {
        let fetchedLists = await listManager.fetchLists()
        if let result = fetchedLists?.results {
            tmdbLists = result.sorted(by: { $0.itemTitle < $1.itemTitle })
            withAnimation { self.isLoading = false }
        }
    }
    
    private var doneButton: some View {
        Button("Done") { showListSelection.toggle() }
    }
    
    private var newList: some View {
        NavigationLink {
#if os(iOS) || os(tvOS)
            NewCustomListView(presentView: $showListSelection, newSelectedList: $selectedList)
#elseif os(macOS)
            NewCustomListView(isPresentingNewList: $isCreateNewListPresented, presentView: $showListSelection, newSelectedList: $selectedList)
#endif
        } label: {
            Label("newList", systemImage: "plus.rectangle.on.rectangle")
        }
    }
    
    private func delete(offsets: IndexSet) {
        withAnimation {
            offsets.map { lists[$0] }.forEach(PersistenceController.shared.delete)
        }
    }
}

enum CustomNavigationMac: String, Identifiable, CaseIterable {
    var id: String { rawValue }
    case newList
}
