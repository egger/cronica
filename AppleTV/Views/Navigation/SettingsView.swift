//
//  SettingsView.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 28/10/22.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("disableTelemetry") private var disableTelemetry = false
    @State private var updatingItems = false
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
            
            Section {
                NavigationLink(destination: TipJarSetting()) {
                    Label("tipJarTitle", systemImage: "heart")
                }
            }
            
            CenterHorizontalView { Text("Made in Brazil 🇧🇷") }
        }
        .navigationTitle("Settings")
    }
    
    private func updateItems() {
        Task {
            let background = BackgroundManager()
            withAnimation {
                self.updatingItems.toggle()
            }
            await background.handleAppRefreshContent()
            withAnimation {
                self.updatingItems.toggle()
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
