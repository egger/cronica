//
//  FeedbackSettingsView.swift
//  Cronica
//
//  Created by Alexandre Madeira on 16/11/22.
//

import SwiftUI

#Preview {
    FeedbackComposerView()
}

struct FeedbackComposerView: View {
    @State private var feedback = ""
    @Environment(\.openURL) var openURL
    @StateObject private var settings = SettingsStore.shared
    @State private var supportEmail = SupportEmail()
    @State private var feedbackSent = false
    @State private var showPopup = false
    @State private var popupType: ActionPopupItems?
    var body: some View {
        Form {
            Section {
                TextField("Feedback", text: $feedback)
                    .lineLimit(4)
                Button("Send", action: send)
                    .disabled(feedback.isEmpty)
#if os(macOS)
                    .buttonStyle(.link)
#endif
            } footer: {
                Text("Feel free to suggest features, improvements, or report bugs.\nYour feedback is crucial to make Cronica better for everyone.")
            }
#if !os(tvOS)
            Section {
                Button("Send Email") { supportEmail.send(openURL: openURL) }
            } footer: {
                HStack {
                    VStack(alignment: .leading) {
                        Text("If you prefer, you can send an email for a faster follow-up.")
                        Text("You can also send an email to contact@alexandremadeira.dev using your email client.")
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
                    UIApplication.shared.open(url)
                }
            } header: {
                Text("On Social Media")
            } footer: {
                Text("Follow Cronica on X/Twitter to stay updated about new features coming soon or to send your feedback/report via DM.")
            }
#endif
        }
        .navigationTitle("Feedback")
        .actionPopup(isShowing: $showPopup, for: popupType)
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
}

extension FeedbackComposerView {
    private func send() {
        if feedback.isEmpty { return }
        CronicaTelemetry.shared.handleMessage("Feedback: \(feedback)", for: "Feedback")
        popupType = .feedbackSent
        withAnimation { showPopup = true }
        feedback = ""
    }
}
