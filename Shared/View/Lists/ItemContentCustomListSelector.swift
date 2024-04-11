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
        NavigationStack {
            Form {
                if isLoading {
                    ProgressView()
                } else {
                    Section {
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
                            .frame(width: 60, height: 90, alignment: .center)
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                            .shadow(radius: 2)
                            VStack(alignment: .leading) {
                                Text(title)
                                    .lineLimit(2)
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                                    .padding(.leading, 4)
                                    .padding(.top, 8)
                                Spacer()
                                if let item {
                                    Text(item.itemMedia.title)
                                        .lineLimit(1)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .fontDesign(.rounded)
                                        .foregroundStyle(.secondary)
                                        .padding(.leading, 4)
                                        .padding(.bottom, 8)
                                }
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
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
            .scrollBounceBehavior(.basedOnSize, axes: .vertical)
#if !os(visionOS) && !os(tvOS)
            .scrollContentBackground(settings.disableTranslucent ? .visible : .hidden)
            .background {
                TranslucentBackground(image: image, useLighterMaterial: true)
            }
#endif
#if os(macOS)
            .formStyle(.grouped)
#endif
            .navigationTitle("Add to...")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .topBarLeading) {
                    RoundedCloseButton { showView.toggle() }
                }
                ToolbarItem(placement: .topBarTrailing) {
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
#if os(iOS)
        .appTint()
        .appTheme()
#elseif os(macOS)
        .frame(width: 500, height: 600, alignment: .center)
#endif
        .presentationDetents([lists.count > 4 ? .large : .medium])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(32)
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
            Image(systemName: "plus.rectangle.on.rectangle")
                .imageScale(.medium)
                .accessibilityLabel("New List")
                .fontDesign(.rounded)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
        }
        .buttonStyle(.borderedProminent)
        .contentShape(Circle())
        .clipShape(Circle())
        .buttonBorderShape(.circle)
        .shadow(radius: 2.5)
    }
}

