//
//  SettingsStore.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 11/05/22.
//

import SwiftUI

class SettingsStore: ObservableObject {
    private init() { }
    static var shared = SettingsStore()
    @AppStorage("showOnboarding") var displayOnboard = true
    @AppStorage("displayDeveloperSettings") var displayDeveloperSettings = false
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
    @AppStorage("allowNotifications") var allowNotifications = true
    @AppStorage("notifyMovies") var notifyMovieRelease = true
    @AppStorage("notifyTVShows") var notifyNewEpisodes = true
    @AppStorage("userHasPurchasedTipJar") var hasPurchasedTipJar = false
    @AppStorage("markPreviouslyEpisodesAsWatched") var markPreviouslyEpisodesAsWatched = false
#if os(tvOS)
    @AppStorage("exploreDisplayType") var exploreDisplayType: ExplorePreferredDisplayType = .poster
#else
    @AppStorage("exploreDisplayType") var exploreDisplayType: ExplorePreferredDisplayType = .card
#endif
    @AppStorage("itemContentListDisplayType") var listsDisplayType: ItemContentListPreferredDisplayType = .standard
    @AppStorage("preferCompactUI") var isCompactUI = false
    @AppStorage("selectedWatchProviderEnabled") var isSelectedWatchProviderEnabled = false
    @AppStorage("selectedWatchProviders") var selectedWatchProviders = ""
    @AppStorage("userHasImportedFromTMDB") var userImportedTMDB = false
    @AppStorage("isUserConnectedWithTMDB") var connectedTMDB = false
    #if os(watchOS)
    @AppStorage("showRemoveConfirmation") var showRemoveConfirmation = true
    #else
    @AppStorage("showRemoveConfirmation") var showRemoveConfirmation = false
    #endif
}
