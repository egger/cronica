//
//  FeedbackSettingsView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 16/11/22.
//

import SwiftUI

struct FeedbackSettingsView: View {
    @State private var email = ""
    @State private var feedback = ""
    @State private var showFeedbackAnimation = false
    @Environment(\.openURL) var openURL
    @StateObject private var settings = SettingsStore.shared
#if os(macOS) || os(iOS)
    @State private var supportEmail = SupportEmail()
    @State private var canSendEmail = true
#endif
    var body: some View {
        ZStack {
            Form {
                Section("Send feedback") {
                    TextField("Feedback", text: $feedback)
                        .lineLimit(4)
                    TextField("Email (optional)", text: $email)
#if os(iOS)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
#endif
                    Button("Send", action: send)
                        .disabled(feedback.isEmpty)
#if os(macOS)
                        .buttonStyle(.link)
#endif
                }
#if os(iOS) || os(macOS)
                Section {
                    Button("sendEmail") { supportEmail.send(openURL: openURL) }
#if os(macOS)
                    .buttonStyle(.link)
#endif
                } footer: {
                    VStack(alignment: .leading) {
                        Text("sendEmailFooter")
                        Text("sendEmailFooterBackup")
                            .textSelection(.enabled)
                    }
                }
#endif
            }
#if os(macOS)
            .formStyle(.grouped)
#endif
            ConfirmationDialogView(showConfirmation: $showFeedbackAnimation,
                                   message: "Feedback sent")
        }
        .navigationTitle("Feedback")
    }
    
    private func send() {
        if feedback.isEmpty { return }
        withAnimation { showFeedbackAnimation.toggle() }
        var message = String()
        if email.isEmpty {
            message = """
                      Feedback: \(feedback)
                      """
        } else {
            message = """
                      Email: \(email)
                      Feedback: \(feedback)
                      """
        }
        CronicaTelemetry.shared.handleMessage(message, for: "Feedback")
        feedback = ""
        email = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation {
                showFeedbackAnimation = false
            }
        }
    }
}

struct FeedbackSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackSettingsView()
    }
}
