//
//  FeedbackSettingsView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 16/11/22.
//

import SwiftUI
#if os(macOS) || os(iOS)
struct FeedbackSettingsView: View {
    @State private var feedback = ""
    @Environment(\.openURL) var openURL
    @StateObject private var settings = SettingsStore.shared
    @State private var supportEmail = SupportEmail()
    @State private var showFeedbackForm = false
    var body: some View {
        Section {
            Button("Send Feedback") {
                showFeedbackForm.toggle()
            }
            .alert("Send Feedback", isPresented: $showFeedbackForm) {
                TextField("Feedback", text: $feedback)
                    .lineLimit(4)
                Button("Send", action: send)
                Button("Cancel") { showFeedbackForm.toggle() }
            }
            #if os(macOS)
            .buttonStyle(.link)
            #endif
            
            Button("sendEmail") { supportEmail.send(openURL: openURL) }
#if os(macOS)
.buttonStyle(.link)
#endif
        } header: {
            Text("Feedback")
        } footer: {
            HStack {
                VStack(alignment: .leading) {
                    Text("sendEmailFooter")
                    Text("sendEmailFooterBackup")
                        .textSelection(.enabled)
                }
                Spacer()
            }
        }
    }
    
    private func send() {
        if feedback.isEmpty { return }
        CronicaTelemetry.shared.handleMessage("Feedback: \(feedback)", for: "Feedback")
        feedback = ""
    }
}

struct FeedbackSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackSettingsView()
    }
}
#endif
