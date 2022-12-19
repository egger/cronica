//
//  AppearanceSetting.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 13/12/22.
//

import SwiftUI

struct AppearanceSetting: View {
    @ObservedObject private var store = SettingsStore.shared
    @AppStorage("newBackgroundStyle") private var newBackgroundStyle = false
    @State private var isExperimentalFeaturesEnabled = false
    @AppStorage("disableTelemetry") private var disableTelemetry = false
    @State private var disableRowType = false
    var body: some View {
        Form {
            Section {
                Picker(selection: $store.rowType) {
                    ForEach(WatchlistSubtitleRow.allCases) { item in
                        Text(item.localizableName).tag(item)
                    }
                } label: {
                    InformationalToggle(title: "appearanceRowTypeTitle",
                                        subtitle: "appearanceRowTypeSubtitle")
                }
                .disabled(disableRowType)
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
            
            Section {
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
                .pickerStyle(.navigationLink)

            } header: {
                Label("appearanceTheme", systemImage: "paintbrush.fill")
            }
            Section {
                Toggle(isOn: $newBackgroundStyle) {
                    InformationalToggle(title: "appearanceBackgroundTitle",
                                        subtitle: "appearanceBackgroundSubtitle")
                }
                if isExperimentalFeaturesEnabled {
                    NavigationLink(destination: FeedbackSettingsView()) {
                        Text("appearanceSendFeedback")
                    }
                }
            } header: {
                Label("appearanceExperimentalHeader", systemImage: "wand.and.stars.inverse")
            } footer: {
                if isExperimentalFeaturesEnabled {
                    Text("appearanceExperimentalFooter")
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