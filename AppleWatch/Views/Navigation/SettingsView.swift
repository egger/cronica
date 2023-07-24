//
//  SettingsView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 17/07/23.
//

import SwiftUI

struct SettingsView: View {
    static let tag: Screens? = .settings
    @StateObject private var store = SettingsStore.shared
    var body: some View {
        NavigationStack {
            Form {
                Section("Watchlist") {
                    Toggle("removeFromPinOnWatchedTitle", isOn: $store.removeFromPinOnWatched)
                    Toggle("showConfirmationOnRemovingItem", isOn: $store.showRemoveConfirmation)
                }
                
#if DEBUG
                Section {
                    NavigationLink("settingsSyncTitle", destination: SyncSetting())
                }
#endif
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
