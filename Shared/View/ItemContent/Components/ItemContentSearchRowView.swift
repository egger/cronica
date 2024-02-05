//
//  ItemContentSearchRowView.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 11/08/23.
//

import SwiftUI

struct ItemContentSearchRowView: View {
	let item: ItemContent
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
				ItemContentRow(item: item)
			} else {
				NavigationLink(value: item) {
					ItemContentRow(item: item)
				}
			}
		} else {
			if isSidebar {
				ItemContentRow(item: item)
					.task {
						isInWatchlist = context.isItemSaved(id: item.itemContentID)
						if isInWatchlist {
							isWatched = context.isMarkedAsWatched(id: item.itemContentID)
						}
					}
					.sheet(isPresented: $showNote) {
                        ReviewView(id: item.itemContentID, showView: $showNote)
					}
					.sheet(isPresented: $showCustomListView) {
                        ItemContentCustomListSelector(contentID: item.itemContentID,
                                                      showView: $showCustomListView,
                                                      title: item.itemTitle,
                                                      image: item.posterImageMedium)
					}
			} else {
				NavigationLink(value: item) {
					ItemContentRow(item: item)
						.task {
							isInWatchlist = context.isItemSaved(id: item.itemContentID)
							if isInWatchlist {
								isWatched = context.isMarkedAsWatched(id: item.itemContentID)
								canReview = true
							}
						}
						.sheet(isPresented: $showNote) {
                            ReviewView(id: item.itemContentID, showView: $showNote)
						}
						.sheet(isPresented: $showCustomListView) {
                            ItemContentCustomListSelector(contentID: item.itemContentID,
                                                          showView: $showCustomListView,
                                                          title: item.itemTitle,
                                                          image: item.posterImageMedium)
						}
				}
			}
			
		}
	}
}

#Preview {
    ItemContentSearchRowView(item: .example, showPopup: .constant(false), popupType: .constant(nil))
}
