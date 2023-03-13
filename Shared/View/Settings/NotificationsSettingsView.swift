//
//  NotificationsSettingsView.swift
//  Story
//
//  Created by Alexandre Madeira on 12/03/23.
//

import SwiftUI

struct NotificationsSettingsView: View {
    @StateObject private var settings = SettingsStore.shared
    var body: some View {
        Form {
            Section {
                Toggle("allowNotification", isOn: $settings.allowNotifications)
                Toggle(isOn: $settings.notifyMovieRelease) {
                    InformationalLabel(title: "movieNotificationTitle",
                                       subtitle: "movieNotificationSubtitle")
                }
                .disabled(!settings.allowNotifications)
                Toggle(isOn: $settings.notifyNewEpisodes) {
                    InformationalLabel(title: "episodeNotificationTitle",
                                       subtitle: "episodeNotificationSubtitle")
                }
                .disabled(!settings.allowNotifications)
            }
            .onChange(of: settings.allowNotifications) { _ in
                if !settings.allowNotifications {
                    settings.notifyMovieRelease = false
                    settings.notifyNewEpisodes = false
                }
            }
        }
        .navigationTitle("settingsNotificationTitle")
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
}

struct NotificationsSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsSettingsView()
    }
}
