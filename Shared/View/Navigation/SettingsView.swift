//
//  SettingsView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 22/03/22.
//

import SwiftUI
import StoreKit
import TelemetryClient

struct SettingsView: View {
    @Environment(\.openURL) var openURL
    @Environment(\.requestReview) var requestReview
    @EnvironmentObject var store: SettingsStore
    @State private var showPolicy = false
    @State private var showFeedbackAlert = false
    @State private var feedback: String = ""
    @Binding var showSettings: Bool
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker(selection: $store.gesture) {
                        Text("Favorites").tag(DoubleTapGesture.favorite)
                        Text("Watched").tag(DoubleTapGesture.watched)
                    } label: {
                        Text("Mark as")
                    }
                    .pickerStyle(.menu)
                } header: {
                    Label("Double Tap Gesture", systemImage: "hand.tap")
                } footer: {
                    Text("The function is performed when double-tap the cover image.")
                        .padding(.bottom)
                }
                Section {
                    Button( action: {
                        showFeedbackAlert = true
                    }, label: {
                        Label("Send feedback", systemImage: "envelope")
                    })
                    .alert("Send Feedback", isPresented: $showFeedbackAlert, actions: {
                        TextField("Feedback", text: $feedback)
                        Button("Send") {
                            sendFeedback()
                        }
                        Button("Cancel", role: .cancel) {
                            cancelFeedback()
                        }
                    }, message: {
                        Text("Send your suggestions to help improve Cronica.")
                    })
                    Button(action: {
                        showPolicy.toggle()
                    }, label: {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    })
                    Button(action: {
                        requestReview()
                    }, label: {
                        Label("Review Cronica", systemImage: "star")
                    })
                } header: {
                    Label("Support", systemImage: "questionmark.circle")
                }
                HStack {
                    Spacer()
                    Text("Made in Brazil 🇧🇷")
                        .font(.caption)
                    Spacer()
                }
                .fullScreenCover(isPresented: $showPolicy) {
                    SFSafariViewWrapper(url: URL(string: "https://cronica.alexandremadeira.dev/privacy")!)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button("Done") {
                        showSettings.toggle()
                    }
                })
            }
        }
    }
    
    private func sendFeedback() {
        if !feedback.isEmpty {
#if targetEnvironment(simulator)
            print("feedback: \(feedback)")
#else
            TelemetryManager.send("feedback", with: ["message":feedback])
#endif
            showFeedbackAlert = false
            feedback = ""
        }
    }
    
    private func cancelFeedback() {
        showFeedbackAlert = false
        feedback = ""
    }
}

struct AccountView_Previews: PreviewProvider {
    @StateObject private static var settings = SettingsStore()
    @State private static var showSettings = false
    static var previews: some View {
        SettingsView(showSettings: $showSettings)
            .environmentObject(settings)
    }
}
