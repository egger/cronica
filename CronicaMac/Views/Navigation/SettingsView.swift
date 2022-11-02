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
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
            PrivacySettingsView()
                .tabItem {
                    Label("Privacy", systemImage: "hand.raised")
                }
            FeedbackSettingsView()
                .tabItem {
                    Label("Support", systemImage: "questionmark.circle")
                }
        }
        .frame(width: 450, height: 250)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

private struct GeneralSettingsView: View {
    var body: some View {
        Form {
            CenterHorizontalView {
                Text("Made in Brazil 🇧🇷")
            }
        }
        .formStyle(.grouped)
    }
}

private struct PrivacySettingsView: View {
    @AppStorage("disableTelemetry") private var disableTelemetry = false
    var body: some View {
        Form {
            Section {
                Toggle("Disable Telemetry", isOn: $disableTelemetry)
            } header: {
                Text("Privacy")
            } footer: {
                Text("privacyfooter")
                    .padding(.bottom)
            }
        }
        .formStyle(.grouped)
    }
}

private struct FeedbackSettingsView: View {
    var body: some View {
        Form {
            
        }
        .formStyle(.grouped)
    }
}
