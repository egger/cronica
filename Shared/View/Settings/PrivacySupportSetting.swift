//
//  PrivacySupportSetting.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 13/12/22.
//

import SwiftUI

struct PrivacySupportSetting: View {
    @AppStorage("disableTelemetry") private var disableTelemetry = false
    @State private var showPolicy = false
    var body: some View {
#if os(iOS)
        Form {
            section
            
        }
        .navigationTitle("Privacy")
#else
        section
#endif
    }
    
    private var section: some View {
        Section {
#if os(iOS) || os(macOS)
            Button {
#if os(macOS)
                NSWorkspace.shared.open(URL(string: "https://alexandremadeira.dev/cronica/privacy")!)
#else
                showPolicy.toggle()
#endif
            } label: {
#if os(iOS)
                Text("settingsPrivacyPolicy")
#else
                Label("settingsPrivacyPolicy", systemImage: "hand.raised.fingers.spread")
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
#if os(tvOS)
            NavigationLink(destination: FeedbackSettingsView()) {
                Label("settingsFeedbackTitle", systemImage: "mail")
            }
            .disabled(disableTelemetry)
#endif
            Toggle(isOn: $disableTelemetry) {
                InformationalLabel(title: "settingsDisableTelemetryTitle",
                                   subtitle: "settingsDisableTelemetrySubtitle")
            }
        } header: {
#if os(tvOS)
            Label("settingsPrivacySupportTitle", systemImage: "hand.wave")
#else
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
