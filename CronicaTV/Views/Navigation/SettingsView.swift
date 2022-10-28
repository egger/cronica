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
                Toggle("Disable Telemetry", isOn: $disableTelemetry)
            } header: {
                Label("Privacy", systemImage: "hand.raised.fingers.spread")
            } footer: {
                Text("privacyFooterTV")
                    .padding(.bottom)
            }
            
            HStack {
                Spacer()
                Text("Made in Brazil 🇧🇷")
                Spacer()
            }
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
