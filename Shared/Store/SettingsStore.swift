//
//  SettingsStore.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 11/05/22.
//

import Foundation

class SettingsStore: ObservableObject {
    @Published var gesture: DoubleTapGesture {
        didSet {
            UserDefaults.standard.set(gesture.rawValue, forKey: "gesture")
        }
    }
    @Published var rowType: WatchlistSubtitleRow {
        didSet {
            UserDefaults.standard.set(rowType.rawValue, forKey: "rowType")
        }
    }
    @Published var appTheme: AppThemeColors {
        didSet {
            UserDefaults.standard.set(appTheme.rawValue, forKey: "appThemeColor")
        }
    }
    init() {
        self.gesture = (UserDefaults.standard.object(forKey: "gesture") == nil ? .favorite : DoubleTapGesture(rawValue: UserDefaults.standard.object(forKey: "gesture") as? Int ?? DoubleTapGesture.favorite.rawValue)) ?? .favorite
        self.rowType = (UserDefaults.standard.object(forKey: "rowType") == nil ? WatchlistSubtitleRow.none : WatchlistSubtitleRow(rawValue: UserDefaults.standard.object(forKey: "rowType") as? Int ?? WatchlistSubtitleRow.none.rawValue)) ?? .none
        self.appTheme = (UserDefaults.standard.object(forKey: "appThemeColor") == nil ? .blue : AppThemeColors(rawValue: UserDefaults.standard.object(forKey: "appThemeColor") as? Int ?? AppThemeColors.blue.rawValue)) ?? .blue
    }
}
