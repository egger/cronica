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
#if os(macOS)
            .buttonStyle(.link)
#endif
            .sheet(isPresented: $showFeedbackForm) {
                NavigationStack {
                    Form {
                        Section {
                            TextField("Feedback", text: $feedback)
                                .lineLimit(4)
                            Button("Send", action: send)
                        }
                        
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
                    }
                    .navigationTitle("Send Feedback")
                    .toolbar {
                        Button("Cancel") { showFeedbackForm.toggle() }
                    }
#if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
#elseif os(macOS)
                    .formStyle(.grouped)
#endif
                }
                .presentationDetents([.medium, .large])
#if os(macOS)
                .frame(width: 400, height: 400, alignment: .center)
#endif
            }
        }
    }
    
    private func send() {
        if feedback.isEmpty { return }
        CronicaTelemetry.shared.handleMessage("Feedback: \(feedback)", for: "Feedback")
        feedback = ""
        showFeedbackForm.toggle()
    }
}

struct FeedbackSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackSettingsView()
    }
}
#endif
