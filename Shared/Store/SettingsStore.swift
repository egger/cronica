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
}
