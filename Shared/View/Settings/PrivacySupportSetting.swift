//
//  PrivacySupportSetting.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 13/12/22.
//

import SwiftUI

struct PrivacySupportSetting: View {
    @StateObject private var settings = SettingsStore.shared
    @State private var showPolicy = false
    var body: some View {
#if os(iOS)
        Form {
            section
            privacyOptionsSection
        }
        .navigationTitle("Privacy")
#elseif os(tvOS)
        Section {
            privacyOptionsSection
        } footer: {
            Text("privacyFooterTV")
                .padding(.bottom)
        }
#else
        section
        privacyOptionsSection
#endif
    }
    
    private var privacyOptionsSection: some View {
        Section {
            Toggle(isOn: $settings.disableTelemetry) {
                InformationalLabel(title: "settingsDisableTelemetryTitle",
                                   subtitle: "settingsDisableTelemetrySubtitle")
            }
        }
    }
    
    private var section: some View {
        Section {
#if os(iOS) || os(macOS)
            Button("settingsPrivacyPolicy") {
#if os(macOS)
                NSWorkspace.shared.open(URL(string: "https://alexandremadeira.dev/cronica/privacy")!)
#else
                showPolicy.toggle()
#endif
            }
#if os(iOS)
            .fullScreenCover(isPresented: $showPolicy) {
                SFSafariViewWrapper(url: URL(string: "https://alexandremadeira.dev/cronica/privacy")!)
            }
#elseif os(macOS)
            .buttonStyle(.link)
#endif
#endif
        } header: {
#if os(macOS) || os(tvOS)
            Label("Privacy", systemImage: "hand.raised")
#endif
        } footer: {
#if os(tvOS)
            Text("privacyFooterTV")
                .padding(.bottom)
#endif
        }
    }
}

struct PrivacySupportSetting_Previews: PreviewProvider {
    static var previews: some View {
        PrivacySupportSetting()
    }
}
