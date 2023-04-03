//
//  SettingsView.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 28/10/22.
//

import SwiftUI
#if os(tvOS)
struct TVSettingsView: View {
    var body: some View {
        Form {
            Section {
                NavigationLink(destination: AppearanceSetting()) {
                    Label("settingsAppearanceTitle", systemImage: "moon.stars")
                }
                NavigationLink(destination: SyncSetting()) {
                    Label("settingsSyncTitle", systemImage: "arrow.triangle.2.circlepath")
                }
            } header: {
                Label("settingsGeneralTitle", systemImage: "wrench.adjustable")
            }
            
            PrivacySupportSetting()
            
            CenterHorizontalView { Text("Made in Brazil 🇧🇷") }
        }
        .navigationTitle("Settings")
    }
}
#endif
