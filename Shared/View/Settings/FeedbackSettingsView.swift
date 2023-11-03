//
//  FeedbackSettingsView.swift
//  Cronica
//
//  Created by Alexandre Madeira on 16/11/22.
//

import SwiftUI

struct FeedbackSettingsView: View {
    @State private var showFeedbackForm = false
    var body: some View {
        Section {
            Button("Send Feedback") {
                showFeedbackForm.toggle()
            }
#if os(macOS)
            .buttonStyle(.link)
#endif
            .sheet(isPresented: $showFeedbackForm) {
                FeedbackComposerView(showFeedbackForm: $showFeedbackForm)
                    .presentationDetents([.medium, .large])
                    .appTheme()
                    .appTint()
#if os(macOS)
                    .frame(width: 400, height: 400, alignment: .center)
#endif
            }
        }
    }
    
    
}

#Preview {
    FeedbackSettingsView()
}

struct FeedbackComposerView: View {
    @State private var feedback = ""
    @Environment(\.openURL) var openURL
    @StateObject private var settings = SettingsStore.shared
    @State private var supportEmail = SupportEmail()
    @Binding var showFeedbackForm: Bool
    @State private var feedbackSent = false
    @State private var showPopup = false
    @State private var popupType: ActionPopupItems?
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Feedback", text: $feedback)
                        .lineLimit(4)
                    Button("Send", action: send)
#if os(macOS)
                        .buttonStyle(.link)
#endif
                }
#if !os(tvOS)
                Section {
                    Button("sendEmail") { supportEmail.send(openURL: openURL) }
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
#if os(macOS)
                .buttonStyle(.link)
#endif
#endif
            }
            .navigationTitle("Send Feedback")
            .toolbar {
                Button("Cancel", role: .cancel) { showFeedbackForm.toggle() }
            }
            .actionPopup(isShowing: $showPopup, for: popupType)
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#elseif os(macOS)
            .formStyle(.grouped)
#endif
        }
    }
    
    private func send() {
        if feedback.isEmpty { return }
        CronicaTelemetry.shared.handleMessage("Feedback: \(feedback)", for: "Feedback")
        popupType = .feedbackSent
        withAnimation { showPopup = true }
        feedback = ""
    }
}
