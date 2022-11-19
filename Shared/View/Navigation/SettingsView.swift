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
                    NavigationLink(destination: MediaSettings()) {
                        Text("Content")
                    }
                } header: {
                    Label("Content", systemImage: "video")
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
                    NavigationLink(destination: FeedbackSettingsView()) {
                        Text("Send Feedback")
                    }
                    .disabled(disableTelemetry)
                    
                } header: {
                    Label("Support", systemImage: "questionmark.circle")
                }
                Section {
                    Button(action: {
                        requestReview()
                    }, label: {
                        Text("Write a review")
                    })
                } header: {
                    Label("Review Cronica", systemImage: "star")
                }
                // MARK: Privacy Section
                Section {
                    NavigationLink("Privacy Policy",
                                   destination: PrivacyPolicySettings())
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
                            Text("Developer")
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
        }
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

private struct MediaSettings: View {
    @AppStorage("useLowData") private var lowData = false
    @AppStorage("openInYouTube") private var openInYouTube = false
    var body: some View {
        Form {
            Section {
                Toggle("Low Data on 3/4G", isOn: $lowData)
            } header: {
                Label("Connection", systemImage: "cellularbars")
            }
            Section {
                Toggle("Open Trailers in YouTube App", isOn: $openInYouTube)
            } header: {
                Label("Links", systemImage: "link")
            }
        }
        .navigationTitle("Media")
    }
}
