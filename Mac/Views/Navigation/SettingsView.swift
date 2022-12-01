//
//  SettingsView.swift
//  CronicaMac
//
//  Created by Alexandre Madeira on 02/11/22.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            WatchlistSettings()
                .tabItem {
                    Label("Watchlist", systemImage: "square.stack")
                }
            PrivacySettings()
                .tabItem {
                    Label("Privacy", systemImage: "hand.raised.fingers.spread")
                }
            SupportSettingsTab()
                .tabItem {
                    Label("Support", systemImage: "questionmark.circle")
                }
            FeaturesPreviewSettings()
                .tabItem {
                    Label("Experimental", systemImage: "wand.and.stars")
                }
        }
        .frame(width: 450, height: 350)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

private struct SupportSettingsTab: View {
    var body: some View {
        FeedbackSettingsView()
    }
}

private struct PrivacySettings: View {
    @AppStorage("disableTelemetry") private var disableTelemetry = false
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Disable Telemetry", isOn: $disableTelemetry)
                    Button("Privacy Policy") {
                        NSWorkspace.shared.open(URL(string: "https://alexandremadeira.dev/cronica/privacy")!)
                    }
                    .buttonStyle(.link)
                } header: {
                    Label("Privacy", systemImage: "hand.raised.fingers.spread")
                } footer: {
                    Text("privacyfooter")
                        .padding(.bottom)
                }
            }
            .formStyle(.grouped)
        }
    }
}
