//
//  WatchlistItemContextMenu.swift
//  Shared
//
//  Created by Alexandre Madeira on 27/10/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct WatchlistItemContextMenu: ViewModifier {
	let item: WatchlistItem
	@Binding var isWatched: Bool
	@Binding var isFavorite: Bool
	@Binding var isPin: Bool
	@Binding var isArchive: Bool
	@Binding var showNote: Bool
	@Binding var showCustomListView: Bool
	@Binding var popupType: ActionPopupItems?
	@Binding var showPopup: Bool
	private let context = PersistenceController.shared
	private let notification = NotificationManager.shared
	@State private var settings = SettingsStore.shared
	func body(content: Content) -> some View {
#if os(watchOS)
#elseif os(tvOS)
		return content
			.contextMenu {
				watchedButton
				favoriteButton
				pinButton
				archiveButton
				deleteButton
			}
#else
		return content
			.swipeActions(edge: .leading, allowsFullSwipe: settings.allowFullSwipe) {
				primaryLeftSwipeActions
				secondaryLeftSwipeActions
			}
			.swipeActions(edge: .trailing, allowsFullSwipe: settings.allowFullSwipe) {
				primaryRightSwipeActions
				secondaryRightSwipeActions
			}
			.contextMenu {
				share
				watchedButton
				favoriteButton
				pinButton
				archiveButton
				customListButton
				reviewButton
				Divider()
				deleteButton
			} preview: {
				ContextMenuPreviewImage(title: item.itemTitle,
										image: item.backCompatibleCardImage,
										overview: String())
			}
#endif
	}
	
	private var watchedButton: some View {
		WatchedButton(id: item.itemContentID,
					  isWatched: $isWatched,
					  popupType: $popupType,
					  showPopup: $showPopup)
	}
	
	private var favoriteButton: some View {
		FavoriteButton(id: item.itemContentID,
					   isFavorite: $isFavorite,
					   popupType: $popupType,
					   showPopup: $showPopup)
	}
	
	private var pinButton: some View {
		PinButton(id: item.itemContentID,
				  isPin: $isPin,
				  popupType: $popupType,
				  showPopup: $showPopup)
	}
	
	private var archiveButton: some View {
		ArchiveButton(id: item.itemContentID,
					  isArchive: $isArchive,
					  popupType: $popupType,
					  showPopup: $showPopup)
	}
	
#if os(iOS) || os(macOS)
	private var customListButton: some View {
		CustomListButton(id: item.itemContentID, showCustomListView: $showCustomListView)
	}
#endif
	
	private var reviewButton: some View {
		Button {
			showNote.toggle()
		} label: {
			Label("reviewTitle", systemImage: "note.text")
		}
	}
	
	@ViewBuilder
	private var share: some View {
#if os(iOS) || os(macOS)
		switch settings.shareLinkPreference {
		case .tmdb: ShareLink(item: item.itemLink)
		case .cronica:
			if let cronicaUrl {
				ShareLink(item: cronicaUrl, message: Text(item.itemTitle))
			} else {
				ShareLink(item: item.itemLink)
			}
		}
		
#else
		EmptyView()
#endif
	}
	
	private var cronicaUrl: URL? {
		let encodedTitle = item.itemTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
		let posterPath = item.posterPath ?? String()
		let encodedPoster = posterPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
		return URL(string: "https://alexandremadeira.dev/cronica/details?id=\(item.itemContentID)&img=\(encodedPoster ?? String())&title=\(encodedTitle ?? String())")
	}
	
	@ViewBuilder
	private var primaryLeftSwipeActions: some View {
		switch settings.primaryLeftSwipe {
		case .markWatch: watchedButton.tint(item.isWatched ? .yellow : .green)
		case .markFavorite: favoriteButton.tint(item.isFavorite ? .orange : .purple)
		case .markPin: pinButton.tint(item.isPin ? .gray : .teal)
		case .markArchive: archiveButton.tint(item.isArchive ? .gray : .indigo)
		case .delete: deleteButton
		case .share: share
		}
	}
	
	@ViewBuilder
	private var secondaryLeftSwipeActions: some View {
		switch settings.secondaryLeftSwipe {
		case .markWatch: watchedButton.tint(item.isWatched ? .yellow : .green)
		case .markFavorite: favoriteButton.tint(item.isFavorite ? .orange : .purple)
		case .markPin: pinButton.tint(item.isPin ? .gray : .teal)
		case .markArchive: archiveButton.tint(item.isArchive ? .gray : .indigo)
		case .delete: deleteButton
		case .share: share
		}
	}
	
	@ViewBuilder
	private var primaryRightSwipeActions: some View {
		switch  settings.primaryRightSwipe {
		case .markWatch: watchedButton.tint(item.isWatched ? .yellow : .green)
		case .markFavorite: favoriteButton.tint(item.isFavorite ? .orange : .purple)
		case .markPin: pinButton.tint(item.isPin ? .gray : .teal)
		case .markArchive: archiveButton.tint(item.isArchive ? .gray : .indigo)
		case .delete: deleteButton
		case .share: share
		}
	}
	
	@ViewBuilder
	private var secondaryRightSwipeActions: some View {
		switch settings.secondaryRightSwipe {
		case .markWatch: watchedButton.tint(item.isWatched ? .yellow : .green)
		case .markFavorite: favoriteButton.tint(item.isFavorite ? .orange : .purple)
		case .markPin: pinButton.tint(item.isPin ? .gray : .teal)
		case .markArchive: archiveButton.tint(item.isArchive ? .gray : .indigo)
		case .delete: deleteButton
		case .share: share
		}
	}
	
	private var deleteButton: some View {
		Button(role: .destructive, action: remove) {
			Label("Remove", systemImage: "minus.circle.fill")
#if os(macOS)
				.labelStyle(.titleOnly)
				.foregroundColor(.red)
#endif
		}
		.tint(.red)
	}
	
	private func remove() {
		notification.removeNotification(identifier: item.itemContentID)
		withAnimation { context.delete(item) }
	}
}
