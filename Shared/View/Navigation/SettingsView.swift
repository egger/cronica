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
                    Toggle("Open Trailers in YouTube App", isOn: $openInYouTube)
                } header: {
                    Label("Links", systemImage: "link")
                }
                
                Section {
                    NavigationLink(destination: WatchlistSettings()) {
                        Text("Watchlist")
                    }
                } header: {
                    Label("Watchlist", systemImage: "square.stack")
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
                .fullScreenCover(isPresented: $showPolicy) {
                    SFSafariViewWrapper(url: URL(string: "https://alexandremadeira.dev/cronica/privacy")!)
                }
                
                Section {
                    NavigationLink {
                        FeaturesPreviewSettings()
                    } label: {
                        Text("Experimental Features")
                    }
                } header: {
                    Label("Experimental Features", systemImage: "wand.and.stars")
                } footer: {
                    Text("Experimental Features are meant for users that want to test out features that still in development.")
                }

                Section {
                    ShareLink("Share App", item: URL(string: "https://apple.co/3TV9SLP")!)
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
                } header: {
                    Label("About", systemImage: "info.circle")
                }
                
                // MARK: Developer Section
                if displayDeveloperSettings {
                    Section {
                        NavigationLink(destination: DeveloperView(),
                                       label: {
                            Text("Developer")
                        })
                        
                    } header: {
                        Label("Developer Tools", systemImage: "hammer")
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


