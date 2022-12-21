//
//  SettingsView.swift
//  CronicaMac
//
//  Created by Alexandre Madeira on 02/11/22.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var settings = SettingsStore.shared
    var body: some View {
        TabView {
            AppearanceSetting()
                .tabItem {
                    Label("settingsAppearanceTitle", systemImage: "moon.stars")
                }
            SyncSetting()
                .tabItem {
                    Label("settingsSyncTitle", systemImage: "arrow.triangle.2.circlepath")
                }
            
            FeedbackSettingsView()
                .tabItem {
                    Label("Feedback", systemImage: "envelope.open.fill")
                }
            
            Form {
                PrivacySupportSetting()
            }
            .formStyle(.grouped)
            .tabItem {
                Label("Privacy", systemImage: "hand.raised.fill")
            }
            
#if DEBUG
            DeveloperView()
                .tabItem {
                    Label("Developer Tools", systemImage: "hammer")
                }
#endif
        }
        .frame(width: 550, height: 320)
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
