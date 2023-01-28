//
//  AcknowledgementsSettings.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 20/12/22.
//

import SwiftUI

struct AcknowledgementsSettings: View {
    var body: some View {
        Form {
            Section {
                Button {
                    openUrl(URL(string: "https://www.fiverr.com/akhmad437")!)
                } label: {
                    InformationalLabel(title: "acknowledgmentsAppIconTitle",
                                       subtitle: "acknowledgmentsAppIconSubtitle")
                }
#if os(macOS)
                .buttonStyle(.link)
#endif
                Button {
                    openUrl(URL(string: "https://www.themoviedb.org")!)
                } label: {
                    InformationalLabel(title: "acknowledgmentsContentProviderTitle",
                                       subtitle: "acknowledgmentsContentProviderSubtitle")
                }
#if os(macOS)
                .buttonStyle(.link)
#endif
                Button {
                    openUrl(URL(string: "https://github.com/SDWebImage/SDWebImageSwiftUI")!)
                } label: {
                    InformationalLabel(title: "acknowledgmentsSDWebImage")
                }
#if os(macOS)
                .buttonStyle(.link)
#endif
                InformationalLabel(title: "acknowledgmentsUserTitle")
            } header: {
                Label("settingsAcknowledgments", systemImage: "smiley")
            } footer: {
                Text("settingsAcknowledgmentsFooter")
            }
        }
        .navigationTitle("acknowledgmentsTitle")
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
    
    private func openUrl(_ url: URL) {
#if os(macOS)
        NSWorkspace.shared.open(url)
#else
        UIApplication.shared.open(url)
#endif
    }
}

struct AcknowledgementsSettings_Previews: PreviewProvider {
    static var previews: some View {
        AcknowledgementsSettings()
    }
}
