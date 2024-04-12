//
//  FeedbackSettingsView.swift
//  Cronica
//
//  Created by Alexandre Madeira on 16/11/22.
//

import SwiftUI

struct FeedbackComposerView: View {
    @Environment(\.openURL) var openURL
    @StateObject private var settings = SettingsStore.shared
    @State private var supportEmail = SupportEmail()
    var body: some View {
        Form {
#if !os(tvOS)
            Section {
                Button("Send Email") { supportEmail.send(openURL: openURL) }
            } footer: {
                HStack {
                    VStack(alignment: .leading) {
                        Text("If you prefer, you can send an email for a faster follow-up.")
                        Text("You can also send an email to cronica@alexandremadeira.dev using your email client.")
                            .textSelection(.enabled)
                    }
                    Spacer()
                }
            }
#if os(macOS)
            .buttonStyle(.link)
#endif
            
            Section {
                Button("X/Twitter") {
                    guard let url = URL(string: "https://x.com/CronicaApp") else { return }
#if os(iOS)
                    UIApplication.shared.open(url)
#elseif os(macOS)
                    NSWorkspace.shared.open(url)
#endif
                }
#if os(macOS)
                .buttonStyle(.link)
#endif
            } header: {
                Text("On Social Media")
            } footer: {
                Text("Follow Cronica on X/Twitter to stay updated about new features coming soon or to send your feedback/report via DM.")
            }
#endif
        }
        .navigationTitle("Feedback")
        .scrollBounceBehavior(.basedOnSize)
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
}

#Preview {
    FeedbackComposerView()
}
