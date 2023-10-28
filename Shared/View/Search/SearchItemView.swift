//
//  SearchItemView.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 30/05/22.
//

import SwiftUI
#if os(iOS) || os(macOS)
struct SearchItemView: View {
    let item: SearchItemContent
    @Binding var showPopup: Bool
    @Binding var popupType: ActionPopupItems?
    @State private var isInWatchlist = false
    @State private var isWatched = false
    @State private var isPin = false
    @State private var isFavorite = false
    @State private var isArchive = false
    @State private var canReview = false
    @State private var showNote = false
    @State private var showCustomListView = false
    private let context = PersistenceController.shared
    var isSidebar = false
    var body: some View {
        if item.media == .person {
            if isSidebar {
                SearchItem(item: item, isInWatchlist: $isInWatchlist, isWatched: $isWatched)
                    .contextMenu { ShareLink(item: item.itemSearchURL) }
            } else {
                NavigationLink(value: item) {
                    SearchItem(item: item, isInWatchlist: $isInWatchlist, isWatched: $isWatched)
                        .contextMenu { ShareLink(item: item.itemSearchURL) }
                }
            }
        } else {
            if isSidebar {
                SearchItem(item: item, isInWatchlist: $isInWatchlist, isWatched: $isWatched)
                    .task {
                        isInWatchlist = context.isItemSaved(id: item.itemContentID)
                        if isInWatchlist {
                            isWatched = context.isMarkedAsWatched(id: item.itemContentID)
                        }
                    }
                    .sheet(isPresented: $showNote) {
#if os(iOS) || os(macOS)
                        NavigationStack {
                            ReviewView(id: item.itemContentID, showView: $showNote)
                        }
                        .presentationDetents([.large])
#if os(macOS)
                        .frame(width: 400, height: 400, alignment: .center)
#elseif os(iOS)
                        .appTheme()
                        .appTint()
#endif
#endif
                    }
                    .sheet(isPresented: $showCustomListView) {
                        NavigationStack {
                            ItemContentCustomListSelector(contentID: item.itemContentID,
                                                          showView: $showCustomListView,
                                                          title: item.itemTitle,
                                                          image: item.cardImageSmall)
                        }
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
#if os(macOS)
                        .frame(width: 500, height: 600, alignment: .center)
#else
                        .appTheme()
                        .appTint()
#endif
                    }
            } else {
                NavigationLink(value: item) {
                    SearchItem(item: item, isInWatchlist: $isInWatchlist, isWatched: $isWatched)
                        .modifier(SearchItemContentContextMenu(item: item,
                                                               showPopup: $showPopup,
                                                               isInWatchlist: $isInWatchlist,
                                                               isWatched: $isWatched,
                                                               showNote: $showNote,
                                                               showCustomListView: $showCustomListView,
                                                               popupType: $popupType))
                        .task {
                            isInWatchlist = context.isItemSaved(id: item.itemContentID)
                            if isInWatchlist {
                                isWatched = context.isMarkedAsWatched(id: item.itemContentID)
                                canReview = true
                            }
                        }
                        .sheet(isPresented: $showNote) {
#if os(iOS) || os(macOS)
                            NavigationStack {
                                ReviewView(id: item.itemContentID, showView: $showNote)
                            }
                            .presentationDetents([.large])
#if os(macOS)
                            .frame(width: 400, height: 400, alignment: .center)
#elseif os(iOS)
                            .appTheme()
                            .appTint()
#endif
#endif
                        }
                        .sheet(isPresented: $showCustomListView) {
                            NavigationStack {
                                ItemContentCustomListSelector(contentID: item.itemContentID,
                                                              showView: $showCustomListView,
                                                              title: item.itemTitle,
                                                              image: item.cardImageSmall)
                            }
                            .presentationDetents([.large])
                            .presentationDragIndicator(.visible)
#if os(macOS)
                            .frame(width: 500, height: 600, alignment: .center)
#else
                            .appTheme()
                            .appTint()
#endif
                        }
                }
            }
            
        }
    }
}
#endif
