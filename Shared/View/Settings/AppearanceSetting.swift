//
//  AppearanceSetting.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 13/12/22.
//

import SwiftUI

struct AppearanceSetting: View {
    @StateObject private var store = SettingsStore.shared
    @AppStorage("newBackgroundStyle") private var newBackgroundStyle = false
    @State private var isExperimentalFeaturesEnabled = false
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
                    InformationalToggle(title: "appearanceRowTypeTitle",
                                        subtitle: "appearanceRowTypeSubtitle")
                }
                .disabled(disableRowType)
#endif
                Picker(selection: $store.watchlistStyle) {
                    ForEach(WatchlistItemType.allCases) { item in
                        Text(item.localizableName).tag(item)
                    }
                } label: {
                    InformationalToggle(title: "appearanceRowStyleTitle",
                                        subtitle: "appearanceRowStyleSubtitle")
                }
                
            } header: {
                Label("appearanceWatchlist", systemImage: "rectangle.stack")
            }
#endif
#if os(iOS) || os(macOS)
            Section {
                Picker(selection: $currentTheme) {
                    ForEach(AppTheme.allCases) { item in
                        Text(item.localizableName).tag(item)
                    }
                } label: {
                    InformationalToggle(title: "appearanceAppThemeTitle")
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
                    InformationalToggle(title: "appearanceThemeTitle")
                }
#if os(macOS)
                .pickerStyle(.automatic)
#else
                .pickerStyle(.navigationLink)
#endif
                
            } header: {
                Label("appearanceTheme", systemImage: "paintbrush.fill")
            }
#endif
            Section {
                Toggle(isOn: $newBackgroundStyle) {
                    InformationalToggle(title: "appearanceBackgroundTitle",
                                        subtitle: "appearanceBackgroundSubtitle")
                }
#if os(iOS)
                if isExperimentalFeaturesEnabled {
                    NavigationLink(destination: FeedbackSettingsView()) {
                        Text("appearanceSendFeedback")
                    }
                }
#endif
            } header: {
                Label("appearanceExperimentalHeader", systemImage: "wand.and.stars.inverse")
            } footer: {
                if isExperimentalFeaturesEnabled {
#if os(macOS)
                    HStack {
                        Text("appearanceExperimentalFooter")
                            .foregroundColor(.secondary)
                            .padding(.leading)
                        Spacer()
                    }
#else
                    Text("appearanceExperimentalFooter")
#endif
                }
            }
            .onChange(of: newBackgroundStyle) { newValue in
                CronicaTelemetry.shared.handleMessage("FeaturesPreview",
                                                      for: "newBackgroundStyle = \(newBackgroundStyle.description)")
                if newValue && !disableTelemetry {
                    isExperimentalFeaturesEnabled = true
                } else {
                    isExperimentalFeaturesEnabled = false
                }
            }
            .onChange(of: store.watchlistStyle) { newValue in
                if newValue != .list {
                    disableRowType = true
                } else {
                    disableRowType = false
                }
            }
        }
        .navigationTitle("appearanceTitle")
        .task {
            if newBackgroundStyle && !disableTelemetry {
                isExperimentalFeaturesEnabled = true
            }
            if store.watchlistStyle != .list { disableRowType = true }
        }
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
}

struct AppearanceSetting_Previews: PreviewProvider {
    @StateObject private static var settings = SettingsStore()
    static var previews: some View {
        AppearanceSetting().environmentObject(settings)
    }
}
