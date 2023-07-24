//
//  ItemContentCustomListSelector.swift
//  Story
//
//  Created by Alexandre Madeira on 21/03/23.
//

import SwiftUI

struct ItemContentCustomListSelector: View {
    @State private var item: WatchlistItem?
    let contentID: String
    @Binding var showView: Bool
    let title: String
    @FetchRequest( sortDescriptors: [NSSortDescriptor(keyPath: \CustomList.title, ascending: true)],
                   animation: .default) private var lists: FetchedResults<CustomList>
    @State private var selectedList: CustomList?
    @State private var isLoading = false
    @State private var settings = SettingsStore.shared
    // TMDb list support
    @State private var listManager = ExternalWatchlistManager.shared
    @State private var tmdbLists = [TMDBListResult]()
    @State private var isLoadingTMDBList = true
    var body: some View {
        Form {
            if isLoading {
                CenterHorizontalView { ProgressView("Loading").padding() }
            } else {
                Section {
                    List {
#if os(watchOS)
                        newList
#else
                        if lists.isEmpty { List { newList } }
#endif
                        ForEach(lists) { list in
                            AddToListRow(list: list, item: $item, showView: $showView)
                                .padding(.vertical, 4)
                        }
                    }
                } header: { Text(title) }
                tmdbSection
            }
        }
        .onAppear(perform: load)
#if os(macOS)
        .formStyle(.grouped)
#endif
        .navigationTitle("addToCustomList")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Done") { showView.toggle() }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if !lists.isEmpty { newList }
            }
#elseif os(macOS)
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") { showView.toggle() }
            }
            ToolbarItem(placement: .automatic) {
                if !lists.isEmpty { newList }
            }
#elseif os(watchOS)
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    showView.toggle()
                } label: {
                    Label("Dismiss", systemImage: "xmark")
                        .labelStyle(.iconOnly)
                }
                
            }
#endif
        }
    }
    
    @ViewBuilder
    private var tmdbSection: some View {
        if SettingsStore.shared.isUserConnectedWithTMDb {
            Section {
                List {
                    ForEach(tmdbLists) { list in
                        TMDBAddToListRow(list: list, item: item, showView: $showView)
                            .environmentObject(listManager)
                            .padding(.vertical, 4)
                    }
                }
            } header: {
                HStack {
                    Text("TMDB")
                    Spacer()
                }
            }
            .redacted(reason: isLoadingTMDBList ? .placeholder : [])
        }
    }
    
    private func load() {
        guard let content = PersistenceController.shared.fetch(for: contentID) else { return }
        self.item = content
        if settings.isUserConnectedWithTMDb { Task { await loadTMDBLists() } }
    }
    
    private func loadTMDBLists() async {
        let fetchedLists = await listManager.fetchLists()
        if let result = fetchedLists?.results {
            tmdbLists = result
            print(tmdbLists)
            withAnimation { self.isLoadingTMDBList = false }
        }
    }
    
    private var newList: some View {
        NavigationLink {
#if os(iOS) || os(tvOS) || os(watchOS)
            NewCustomListView(presentView: $showView, preSelectedItem: item, newSelectedList: $selectedList)
#elseif os(macOS)
            NewCustomListView(isPresentingNewList: $showView,
                              presentView: $showView,
                              preSelectedItem: item,
                              newSelectedList: $selectedList)
#endif
        } label: {
            Label("newList", systemImage: "plus.rectangle.on.rectangle")
        }
    }
}

