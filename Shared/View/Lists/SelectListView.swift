//
//  SelectListView.swift
//  Cronica (iOS)
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
#if os(macOS)
    @State private var isCreateNewListPresented = false
#endif
    @State private var isEditing = false
    @State private var query = String()
    @State private var queryResult = [CustomList]()
    @State private var isSearchingLists = false
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
#if os(iOS)
                .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
                .autocorrectionDisabled()
                .task(id: query) {
                    await search()
                }
#endif
#else
            form
                .formStyle(.grouped)
                .toolbar {
                    #if !os(visionOS)
                    if !isCreateNewListPresented {
                        ToolbarItem(placement: .automatic) {
                            if !lists.isEmpty { newList }
                        }
                    }
                    #endif
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
                    if queryResult.isEmpty && query.isEmpty {
                        DefaultListRow(selectedList: $selectedList)
                            .onTapGesture {
                                HapticManager.shared.selectionHaptic()
                                selectedList = nil
                                showListSelection.toggle()
                            }
                    }
                    // if empty, offers a more visual way to create new list
                    if lists.isEmpty { newList }
                    else  {
                        if !queryResult.isEmpty {
#if os(iOS)
                            ForEach(queryResult) { item in
                                ListRowItem(list: item, selectedList: $selectedList)
                                    .onTapGesture {
                                        HapticManager.shared.selectionHaptic()
                                        selectedList = item
                                        showListSelection = false
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: SettingsStore.shared.allowFullSwipe) {
                                        NavigationLink("Edit") {
                                            EditCustomList(list: item, showListSelection: $showListSelection)
                                        }
                                    }
                            }
#endif
                        } else if !query.isEmpty && queryResult.isEmpty {
                            if isSearchingLists {
                                ProgressView()
                            } else {
                                CenterHorizontalView {
                                    SearchContentUnavailableView(query: query)
                                }
                            }
                        } else {
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
                                        showListSelection = false
                                    }
#if os(iOS) || os(macOS)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: SettingsStore.shared.allowFullSwipe) {
                                        NavigationLink {
#if os(iOS)
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
                }
            } header: {
                HStack {
                    Text("Your Lists")
                    Spacer()
                }
            } footer: {
                HStack {
                    Text("Swipe to Edit your list")
#if os(macOS)
                        .foregroundStyle(.secondary)
#endif
                    Spacer()
                }
            }
        }
        .navigationDestination(for: ItemContent.self) { item in
            ItemContentDetails(title: item.itemTitle,
                               id: item.id,
                               type: item.itemContentMedia)
        }
        .navigationDestination(for: Person.self) { person in
            PersonDetailsView(name: person.name, id: person.id)
        }
        .navigationDestination(for: [String:[ItemContent]].self) { item in
            let keys = item.map { (key, _) in key }.first
            let value = item.map { (_, value) in value }.first
            if let keys, let value {
                ItemContentSectionDetails(title: keys, items: value)
            }
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
    }
    
    private func search() async {
        isSearchingLists = true
        try? await Task.sleep(nanoseconds: 300_000_000)
        if query.isEmpty && !queryResult.isEmpty { queryResult = [] }
        if query.isEmpty { return }
        if !queryResult.isEmpty { queryResult.removeAll() }
        queryResult.append(contentsOf: lists.filter {
            ($0.itemTitle.localizedStandardContains(query.lowercased())) as Bool
        })
        isSearchingLists = false
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
            Label("New List", systemImage: "plus.rectangle.on.rectangle")
        }
    }
    
    private func delete(offsets: IndexSet) {
        withAnimation {
            offsets.map { lists[$0] }.forEach(PersistenceController.shared.delete)
        }
    }
}

#Preview {
    SelectListView(
        selectedList: .constant(
            nil
        ),
        navigationTitle: .constant(
            "Preview"
        ),
        showListSelection: .constant(
            true
        )
    )
}

enum CustomNavigationMac: String, Identifiable, CaseIterable {
    var id: String { rawValue }
    case newList
}
