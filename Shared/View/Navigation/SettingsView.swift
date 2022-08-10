//
//  SettingsView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 22/03/22.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.openURL) var openURL
    @Environment(\.requestReview) var requestReview
    @EnvironmentObject var store: SettingsStore
    @State private var email = SupportEmail()
    @State private var showPolicy = false
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
                    Picker(selection: $store.useLegacy) {
                        Text("Legacy").tag(UseLegacyWatchlist.legacy)
                        Text("New").tag(UseLegacyWatchlist.new)
                    } label: {
                        Text("Watchlist Mode")
                    }
                    .pickerStyle(.menu)
                } header: {
                    Label("Watchlist", systemImage: "square.stack")
                } footer: {
                    Text("The legacy watchlist do not support custom lists.")
                        .padding(.bottom)
                }
                
                Section {
                    Button( action: {
                        email.send(openURL: openURL)
                    }, label: {
                        Label("Send feedback", systemImage: "envelope")
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
}

struct AccountView_Previews: PreviewProvider {
    @StateObject private static var settings = SettingsStore()
    @State private static var showSettings = false
    static var previews: some View {
        SettingsView(showSettings: $showSettings)
            .environmentObject(settings)
    }
}
