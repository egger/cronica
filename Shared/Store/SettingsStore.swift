//
//  SettingsStore.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 11/05/22.
//

import SwiftUI

class SettingsStore: ObservableObject {
    static var shared = SettingsStore()
    @AppStorage("gesture") var gesture: DoubleTapGesture = .favorite
    @AppStorage("rowType") var rowType: WatchlistSubtitleRow = .none
    @AppStorage("appThemeColor") var appTheme: AppThemeColors = .blue
#if os(macOS)
    @AppStorage("watchlistStyle") var watchlistStyle: WatchlistItemType = .poster
#else
    @AppStorage("watchlistStyle") var watchlistStyle: WatchlistItemType = .list
#endif
    @AppStorage("disableTranslucentBackground") var disableTranslucent = false
    @AppStorage("disableTelemetry") var disableTelemetry = false
    @AppStorage("deleteConfirmation") var deleteConfirmation = false
    @AppStorage("user_theme") var currentTheme: AppTheme = .system
    @AppStorage("openInYouTube") var openInYouTube = false
    @AppStorage("markEpisodeWatchedTap") var markEpisodeWatchedOnTap = false
    @AppStorage("enableHapticFeedback") var hapticFeedback = true
    @AppStorage("enableWatchProviders") var isWatchProviderEnabled = true
    @AppStorage("selectedWatchProviderRegion") var watchRegion: WatchProviderOption = .us
    @AppStorage("primaryLeftSwipe") var primaryLeftSwipe: SwipeGestureOptions = .markWatch
    @AppStorage("secondaryLeftSwipe") var secondaryLeftSwipe: SwipeGestureOptions = .markFavorite
    @AppStorage("primaryRightSwipe") var primaryRightSwipe: SwipeGestureOptions = .delete
    @AppStorage("secondaryRightSwipe") var secondaryRightSwipe: SwipeGestureOptions = .markArchive
    @AppStorage("allowFullSwipe") var allowFullSwipe = false
    @AppStorage("displayCustomListItemsOnWatchlist") var displayCustomOnWatchlist = true
    @AppStorage("immediatelyDeleteItem") var immediatelyDeletion = false
    @AppStorage("allowNotifications") var allowNotifications = true
    @AppStorage("notifyMovies") var notifyMovieRelease = true
    @AppStorage("notifyTVShows") var notifyNewEpisodes = true
}
