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
    @AppStorage("gesture") var gesture: UpdateItemProperties = .favorite
    @AppStorage("appThemeColor") var appTheme: AppThemeColors = .blue
    @AppStorage("watchlistStyle") var watchlistStyle: WatchlistItemType = .card
    @AppStorage("disableTranslucentBackground") var disableTranslucent = false
    @AppStorage("user_theme") var currentTheme: AppTheme = .system
    @AppStorage("openInYouTube") var openInYouTube = false
    @AppStorage("markEpisodeWatchedTap") var markEpisodeWatchedOnTap = false
    @AppStorage("enableHapticFeedback") var hapticFeedback = true
    @AppStorage("enableWatchProviders") var isWatchProviderEnabled = true
    @AppStorage("selectedWatchProviderRegion") var watchRegion: AppContentRegion = .us
    @AppStorage("primaryLeftSwipe") var primaryLeftSwipe: SwipeGestureOptions = .markWatch
    @AppStorage("secondaryLeftSwipe") var secondaryLeftSwipe: SwipeGestureOptions = .markFavorite
    @AppStorage("primaryRightSwipe") var primaryRightSwipe: SwipeGestureOptions = .delete
    @AppStorage("secondaryRightSwipe") var secondaryRightSwipe: SwipeGestureOptions = .markArchive
    @AppStorage("allowFullSwipe") var allowFullSwipe = false
    @AppStorage("allowNotifications") var allowNotifications = true
    @AppStorage("notifyMovies") var notifyMovieRelease = true
    @AppStorage("notifyTVShows") var notifyNewEpisodes = true
    @AppStorage("userHasPurchasedTipJar") var hasPurchasedTipJar = false
#if os(tvOS)
    @AppStorage("itemContentListDisplayType") var listsDisplayType: ItemContentListPreferredDisplayType = .card
#else
    @AppStorage("itemContentListDisplayType") var listsDisplayType: ItemContentListPreferredDisplayType = .standard
#endif
    @AppStorage("exploreDisplayType") var exploreDisplayType: ExplorePreferredDisplayType = .card
    @AppStorage("preferCompactUI") var isCompactUI = false
    @AppStorage("selectedWatchProviderEnabled") var isSelectedWatchProviderEnabled = false
    @AppStorage("selectedWatchProviders") var selectedWatchProviders = ""
    @AppStorage("userHasImportedFromTMDB") var userImportedTMDB = false
    @AppStorage("isUserConnectedWithTMDB") var isUserConnectedWithTMDb = false
#if os(tvOS) || os(watchOS)
    @AppStorage("showRemoveConfirmation") var showRemoveConfirmation = true
#else
    @AppStorage("showRemoveConfirmation") var showRemoveConfirmation = false
#endif
    @AppStorage("choosePreferredLaunchScreen") var isPreferredLaunchScreenEnabled = false
#if !os(watchOS)
    @AppStorage("preferredLaunchScreen") var preferredLaunchScreen: Screens = .home
#else
    @AppStorage("preferredLaunchScreen") var preferredLaunchScreen: Screens = .watchlist
#endif
    @AppStorage("removeFromPinOnWatched") var removeFromPinOnWatched = false
    @AppStorage("autoOpenCustomListSelector") var openListSelectorOnAdding = false
#if os(iOS)
    @AppStorage("alwaysUsePosterAsCover") var usePostersAsCover = true
#endif
}
