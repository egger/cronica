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
					NavigationLink("Behavior", destination: BehaviorSetting())
				}
                
				Section {
					NavigationLink("Sync", destination: SyncSetting())
				}
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    SettingsView()
}
