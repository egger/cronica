//
//  AppearanceSetting.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 13/12/22.
//

import SwiftUI

struct AppearanceSetting: View {
    @StateObject private var store = SettingsStore.shared
    @AppStorage("disableTranslucentBackground") private var disableTranslucent = false
    @AppStorage("disableTelemetry") private var disableTelemetry = false
    @AppStorage("user_theme") private var currentTheme: AppTheme = .system
    @State private var disableRowType = false
    var body: some View {
        Form {
#if os(iOS) || os(macOS)
            Section {
#if os(iOS)
                Picker(selection: $store.rowType) {
                    ForEach(WatchlistSubtitleRow.allCases) { item in
                        Text(item.localizableName).tag(item)
                    }
                } label: {
                    InformationalLabel(title: "appearanceRowTypeTitle",
                                        subtitle: "appearanceRowTypeSubtitle")
                }
                .disabled(disableRowType)
#endif
                Picker(selection: $store.watchlistStyle) {
                    ForEach(WatchlistItemType.allCases) { item in
                        Text(item.localizableName).tag(item)
                    }
                } label: {
                    InformationalLabel(title: "appearanceRowStyleTitle",
                                        subtitle: "appearanceRowStyleSubtitle")
                }
                
            } header: {
                Label("appearanceWatchlist", systemImage: "rectangle.stack")
            }
            .onChange(of: store.watchlistStyle) { newValue in
                if newValue != .list {
                    disableRowType = true
                } else {
                    disableRowType = false
                }
            }
#endif
#if os(iOS)
            Section {
                
                Picker(selection: $currentTheme) {
                    ForEach(AppTheme.allCases) { item in
                        Text(item.localizableName).tag(item)
                    }
                } label: {
                    InformationalLabel(title: "appearanceAppThemeTitle")
                }
                
                Picker(selection: $store.appTheme) {
                    ForEach(AppThemeColors.allCases.sorted { $0.localizableName < $1.localizableName }) { item in
                        HStack {
                            Circle()
                                .fill(item.color)
                                .frame(width: 25)
                            Text(item.localizableName)
                        }
                        .tag(item)
                    }
                } label: {
                    InformationalLabel(title: "appearanceThemeTitle")
                }
                .pickerStyle(.navigationLink)
            } header: {
                Label("appearanceTheme", systemImage: "paintbrush.fill")
            }
#endif
            Section {
                Toggle(isOn: $disableTranslucent) {
                    InformationalLabel(title: "disableTranslucentTitle")
                }
            } header: {
                Label("accessibilityTitle", systemImage: "eyeglasses")
            }
            .onChange(of: disableTranslucent) { newValue in
                CronicaTelemetry.shared.handleMessage("accessibilityDisableTranslucent is turned \(newValue)", for: "AppearanceSetting")
            }
        }
        .navigationTitle("appearanceTitle")
        .task {
            if store.watchlistStyle != .list { disableRowType = true }
        }
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
}

struct AppearanceSetting_Previews: PreviewProvider {
    static var previews: some View {
        AppearanceSetting()
    }
}
