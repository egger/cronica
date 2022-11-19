//
//  PrivacyPolicySettings.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 18/11/22.
//

import SwiftUI

struct PrivacyPolicySettings: View {
    var body: some View {
        VStack {
            ScrollView {
                Text("""
Cronica is a privacy-first app to track your movies and TV shows. Cronica does not sell or rent your data and minimal data is collected only to minimize app crashes and provide feedback feature, this data is fully anonymous.

If you opt to sync your watchlist with iCloud, your data will be backed up to Apple’s servers, this data is not accessible or visible to the app developer.

The app uses the TelemetryDeck service to collect information about crashes, these information consists of a random User ID, App Version, Locale, Device Model Name, OS version, and system version.

If you opt to disable crash reports, some functionality will be disabled, such as Send Feedback, theses functionalities rely on the TelemetryDeck service to work.
After disabling it, the developer will not receive the crash reports.

To provide the data used for the app content, Cronica utilizes the TMDb API. Minimal information is collected by TMDb to provide this functionality, such as your IP address, for more information you can check out TMDb Privacy Policy terms.

Cronica is offered as an open-source project, except for the API Keys, you can see every line of code of this app on GitHub.

For any question, you can send an email to the developer at contact@alexandremadeira.dev.
""")
                    .padding()
                
            }
        }
        .navigationTitle("Privacy Policy")
    }
}

struct PrivacyPolicySettings_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicySettings()
    }
}
