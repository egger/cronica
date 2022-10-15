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
    @State private var updatingItems = false
    @Binding var showSettings: Bool
    @AppStorage("displayDeveloperSettings") private var displayDeveloperSettings = false
    @AppStorage("disableTelemetry") private var disableTelemetry = false
    @AppStorage("openInYouTube") private var openInYouTube = false
    @State private var animateEasterEgg = false
    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    // MARK: Gesture Section
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
                    // MARK: Media Section
                    Section {
                        Toggle("Open Trailers in YouTube App", isOn: $openInYouTube)
                    } header: {
                        Label("Media", systemImage: "video")
                    }
                    // MARK: Update Section
                    Section {
                        Button(action: {
                            updateItems()
                        }, label: {
                            if updatingItems {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                            } else {
                                Text("Update Items")
                            }
                        })
                    } header: {
                        Label("Sync", systemImage: "arrow.2.circlepath")
                    } footer: {
                        Text("'Update Items' will update your items with new information available on TMDb, if available.")
                            .padding(.bottom)
                    }
                    // MARK: Support Section
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
                        .disabled(disableTelemetry)
                        Button(action: {
                            requestReview()
                        }, label: {
                            Label("Review Cronica", systemImage: "star")
                        })
                    } header: {
                        Label("Support", systemImage: "questionmark.circle")
                    }
                    // MARK: Privacy Section
                    Section {
                        Button("Privacy Policy") {
                            showPolicy.toggle()
                        }
                        Toggle("Disable Telemetry", isOn: $disableTelemetry)
                    } header: {
                        Label("Privacy", systemImage: "hand.raised")
                    } footer: {
                        Text("privacyfooter")
                            .padding(.bottom)
                    }
                    // MARK: Developer Section
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
                    HStack {
                        Spacer()
                        Text("Made in Brazil 🇧🇷")
                            .onTapGesture {
                                Task {
                                    withAnimation {
                                        self.animateEasterEgg.toggle()
                                    }
                                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                                    withAnimation {
                                        self.animateEasterEgg.toggle()
                                    }
                                }
                            }
                            .onLongPressGesture(perform: {
                                displayDeveloperSettings.toggle()
                            })
                            .font(animateEasterEgg ? .title3 : .caption)
                            .foregroundColor(animateEasterEgg ? .green : nil)
                            .animation(.easeInOut, value: animateEasterEgg)
                        Spacer()
                    }
                    .fullScreenCover(isPresented: $showPolicy) {
                        SFSafariViewWrapper(url: URL(string: "https://alexandremadeira.dev/cronica/privacy")!)
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
            TelemetryErrorManager.shared.handleErrorMessage(feedback, for: "sendFeedback")
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
    
    private func updateItems() {
        Task {
            let background = BackgroundManager()
            withAnimation {
                self.updatingItems.toggle()
            }
            await background.handleAppRefreshContent()
            withAnimation {
                self.updatingItems.toggle()
            }
        }
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
