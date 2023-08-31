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
				Section {
					NavigationLink("settingsBehaviorTitle", destination: BehaviorSettings())
				}
                
				Section {
					NavigationLink("settingsSyncTitle", destination: SyncSetting())
				}
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

private struct BehaviorSettings: View {
	@StateObject private var store = SettingsStore.shared
	var body: some View {
		Form {
			Section("Watchlist") {
				Toggle("removeFromPinOnWatchedTitle", isOn: $store.removeFromPinOnWatched)
				Toggle("showConfirmationOnRemovingItem", isOn: $store.showRemoveConfirmation)
			}
			Section {
				Picker(selection: $store.shareLinkPreference) {
					ForEach(ShareLinkPreference.allCases) { item in
						Text(item.title).tag(item)
					}
				} label: {
					Text("shareLinkPreference")
				}
			} header: {
				Text("Beta")
			} footer: {
				HStack {
					Text("shareLinkPreferenceSubtitle")
					Spacer()
				}
			}
		}
	}
}
