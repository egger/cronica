//
//  NotificationsSettingsView.swift
//  Cronica
//
//  Created by Alexandre Madeira on 12/03/23.
//

import SwiftUI

struct NotificationsSettingsView: View {
    var navigationTitle = "settingsNotificationTitle"
    @StateObject private var settings = SettingsStore.shared
    var body: some View {
        Form {
            Section {
                Toggle("allowNotification", isOn: $settings.allowNotifications)
                Toggle(isOn: $settings.notifyMovieRelease) {
					Text("movieNotificationTitle")
					Text("movieNotificationSubtitle")
                }
                .disabled(!settings.allowNotifications)
                Toggle(isOn: $settings.notifyNewEpisodes) {
					Text("episodeNotificationTitle")
					Text("episodeNotificationSubtitle")
                }
                .disabled(!settings.allowNotifications)
                
            }
            .onChange(of: settings.allowNotifications) { _ in
                if !settings.allowNotifications {
                    settings.notifyMovieRelease = false
                    settings.notifyNewEpisodes = false
                }
            }
            
            Button("openNotificationInSettings") {
                Task {
#if os(iOS)
                    // Create the URL that deep links to your app's notification settings.
                    if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
                        // Ask the system to open that URL.
                        await UIApplication.shared.open(url)
                    }
#endif
                }
            }
        }
        .navigationTitle(NSLocalizedString(navigationTitle, comment: ""))
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
