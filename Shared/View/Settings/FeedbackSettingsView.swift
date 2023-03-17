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
    @AppStorage("disableTelemetry") private var disableTelemetry = false
    @Environment(\.openURL) var openURL
    @StateObject private var settings = SettingsStore.shared
#if os(macOS) || os(iOS)
    @State private var supportEmail = SupportEmail()
#endif
    var body: some View {
        ZStack {
            Form {
                Section {
                    TextField("Feedback", text: $feedback)
                        .lineLimit(4)
                        .disabled(settings.disableTelemetry)
                    TextField("Email (optional)", text: $email)
                        .disabled(settings.disableTelemetry)
#if os(iOS)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
#endif
                    Button("Send") {
                        send()
                    }
                    .disabled(feedback.isEmpty || disableTelemetry)
#if os(macOS)
                    .buttonStyle(.link)
#endif
                } header: {
                    Text("Send feedback")
                } footer: {
#if os(iOS)
                    if disableTelemetry {
                        Text("cantSendFeedback")
                    } else {
                        Text("Send your suggestions to help improve Cronica.")
                    }
#endif
                }
#if os(iOS) || os(macOS)
                Section {
                    Button {
                        supportEmail.send(openURL: openURL)
                    } label: {
                        Label("sendEmail", systemImage: "envelope.open.fill")
                    }
#if os(macOS)
                    .buttonStyle(.link)
#endif
                } footer: {
#if os(iOS)
                    Text("sendEmailFooter")
#else
                    HStack {
                        Text("sendEmailFooter")
                        Spacer()
                    }
#endif
                }
#endif
            }
#if os(macOS)
            .formStyle(.grouped)
#endif
            ConfirmationDialogView(showConfirmation: $showFeedbackAnimation,
                                   message: "Feedback sent",
                                   image: "envelope.badge")
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
