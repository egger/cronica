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
                    
                    Section {
                        NavigationLink {
                            GesturesSettingsView()
                                .environmentObject(store)
                        } label: {
                            Text("Gestures")
                        }
                    } header: {
                        Label("Gestures", systemImage: "hand.tap")
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
                                CenterHorizontalView {
                                    ProgressView()
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
                    
                    Section {
                        NavigationLink {
                            FeaturePreviewSettings()
                        } label: {
                            Text("Experimental Features")
                        }
                    } header: {
                        Label("Experimental Features", systemImage: "wand.and.stars")
                    } footer: {
                        Text("Experimental Features are meant for users that want to test out features that still in development.")
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
                    CenterHorizontalView {
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

struct GesturesSettingsView: View {
    @EnvironmentObject var store: SettingsStore
    @AppStorage("markEpisodeWatchedTap") private var markEpisodeWatchedOnTap = false
    @AppStorage("showPinSwipeButton") private var pinAsSwipe = false
    var body: some View {
        Form {
            Section {
                Picker(selection: $store.gesture) {
                    Text("Favorites").tag(DoubleTapGesture.favorite)
                    Text("Watched").tag(DoubleTapGesture.watched)
                } label: {
                    Text("Double Tap Gesture")
                }
                .pickerStyle(.menu)
            } header: {
                Label("Cover Image Gesture", systemImage: "hand.tap")
            } footer: {
                Text("The function is performed when double-tap the cover image.")
                    .padding(.bottom)
            }
            
            Section {
                Toggle("Tap To Mark as Watched",
                       isOn: $markEpisodeWatchedOnTap)
            } header: {
                Label("Episode Gesture", systemImage: "tv")
            } footer: {
                Text("This will mark an episode as watched on tap gesture.")
            }
            
            Section {
                Toggle("Show Pin On Swipe", isOn: $pinAsSwipe)
            } header: {
                Label("Watchlist Gesture", systemImage: "square.stack")
            }
        }
        .navigationTitle("Gestures")
    }
}

private struct FeaturePreviewSettings: View {
    @AppStorage("newBackgroundStyle") private var newBackgroundStyle = false
    @AppStorage("showPinOnSearch") private var pinOnSearch = false
    var body: some View {
        Form {
            Section {
                Toggle("Translucent Background", isOn: $newBackgroundStyle)
            } header: {
                Label("Appearance", systemImage: "doc.text.image.fill")
            }
            Section {
                Toggle("Pin on Search", isOn: $pinOnSearch)
            } footer: {
                Text("Shows Pin feature on right swipe.")
            }
        }
        .navigationTitle("Experimental Features")
    }
}
