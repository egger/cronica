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
    @State private var feedbackSent = false
    @Binding var showSettings: Bool
    @AppStorage("displayDeveloperSettings") var displayDeveloperSettings: Bool?
    var body: some View {
        NavigationStack {
            ZStack {
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
                            //.disabled((feedback.isEmpty) ? true : false)
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
                            .onTapGesture(count: 3, perform: {
                                if let displayDeveloperSettings {
                                    self.displayDeveloperSettings = !displayDeveloperSettings
                                }
                                displayDeveloperSettings = true
                            })
                            .font(.caption)
                        Spacer()
                    }
                    .fullScreenCover(isPresented: $showPolicy) {
                        SFSafariViewWrapper(url: URL(string: "https://alexandremadeira.dev/cronica/privacy")!)
                    }
                    if let displayDeveloperSettings {
                        if displayDeveloperSettings {
                            Section {

                                NavigationLink(destination: DeveloperView(),
                                               label: {
                                    Label("Developer", systemImage: "hammer.fill")
                                })

                            } header: {
                                Label("Developer Options", systemImage: "hammer")
                            }
                        }
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
                ConfirmationDialogView(showConfirmation: $feedbackSent, message: "Feedback sent", image: "envelope.badge")
            }
        }
    }
    
    private func sendFeedback() {
        if !feedback.isEmpty {
            withAnimation { feedbackSent.toggle() }
#if targetEnvironment(simulator)
            print("feedback: \(feedback)")
#else
            TelemetryManager.send("feedback", with: ["message":feedback])
#endif
            feedback = ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation {
                    feedbackSent = false
                }
            }
        }
    }
    
    private func cancelFeedback() {
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
