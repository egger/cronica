//
//  NotificationsSettingsView.swift
//  Cronica
//
//  Created by Alexandre Madeira on 12/03/23.
//

import SwiftUI

struct NotificationsSettingsView: View {
    var navigationTitle = "Notifications"
    @StateObject private var settings = SettingsStore.shared
    var body: some View {
        Form {
            Section {
                Toggle("Allow Notification", isOn: $settings.allowNotifications)
                Toggle(isOn: $settings.notifyMovieRelease) {
                    Text("Notify Movies Releases")
                    Text("Notify when a movie on your watchlist is released.")
                }
                .disabled(!settings.allowNotifications)
                Toggle(isOn: $settings.notifyNewEpisodes) {
                    Text("Notify New Episodes")
                    Text("Notify when a new episode from a TV Show on your watchlist is released.")
                }
                .disabled(!settings.allowNotifications)
                
            }
            .onChange(of: settings.allowNotifications) {
                if !settings.allowNotifications {
                    settings.notifyMovieRelease = false
                    settings.notifyNewEpisodes = false
                }
            }
#if os(iOS)
            Button("Edit Notifications in Settings app") {
                Task {
                    // Create the URL that deep links to your app's notification settings.
                    if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
                        // Ask the system to open that URL.
                        await UIApplication.shared.open(url)
                    }
                }
            }
#endif
        }
        .navigationTitle(NSLocalizedString(navigationTitle, comment: ""))
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
}

#Preview {
    NotificationsSettingsView()
}
