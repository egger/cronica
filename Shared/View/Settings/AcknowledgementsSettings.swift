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
                    InformationalToggle(title: "acknowledgmentsAppIconTitle",
                                        subtitle: "acknowledgmentsAppIconSubtitle")
                }
                Button {
                    openUrl(URL(string: "https://www.themoviedb.org")!)
                } label: {
                    InformationalToggle(title: "acknowledgmentsContentProviderTitle",
                                        subtitle: "acknowledgmentsContentProviderSubtitle")
                }
                Button {
                    openUrl(URL(string: "https://github.com/SDWebImage/SDWebImageSwiftUI")!)
                } label: {
                    InformationalToggle(title: "acknowledgmentsSDWebImage")
                }
            } header: {
                Label("settingsAcknowledgments", systemImage: "smiley")
            } footer: {
                Text("settingsAcknowledgmentsFooter")
            }
        }
        .navigationTitle("acknowledgmentsTitle")
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
