//
//  ItemContentCustomListSelector.swift
//  Cronica
//
//  Created by Alexandre Madeira on 21/03/23.
//

import SwiftUI
import NukeUI

struct ItemContentCustomListSelector: View {
    @State private var item: WatchlistItem?
    let contentID: String
    @Binding var showView: Bool
    let title: String
    let image: URL?
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \CustomList.title, ascending: true)],
                  animation: .default) private var lists: FetchedResults<CustomList>
    @State private var selectedList: CustomList?
    @State private var isLoading = false
    @State private var settings = SettingsStore.shared
    var body: some View {
        Form {
            if isLoading {
                ProgressView()
            } else {
                HStack {
                    LazyImage(url: image) { state in
                        if let image = state.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            ZStack {
                                Rectangle().fill(.gray.gradient)
                                Image(systemName: "popcorn.fill")
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                    }
                    .frame(width: 70, height: 50, alignment: .center)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .shadow(radius: 2)
                    Text(title)
                        .lineLimit(2)
                        .fontDesign(.rounded)
                        .padding(.leading, 4)
                }
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
                } header: { Text("Your Lists") }
            }
        }
        .onAppear(perform: load)
#if os(macOS)
        .formStyle(.grouped)
#endif
        .navigationTitle("Add to...")
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
#elseif os(macOS) || os(visionOS)
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
    
    private func load() {
        guard let content = PersistenceController.shared.fetch(for: contentID) else { return }
        self.item = content
    }
    
    private var newList: some View {
        NavigationLink {
#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
            NewCustomListView(presentView: $showView, preSelectedItem: item, newSelectedList: $selectedList)
#elseif os(macOS)
            NewCustomListView(isPresentingNewList: $showView,
                              presentView: $showView,
                              preSelectedItem: item,
                              newSelectedList: $selectedList)
#endif
        } label: {
            Label("New List", systemImage: "plus.rectangle.on.rectangle")
        }
    }
}

