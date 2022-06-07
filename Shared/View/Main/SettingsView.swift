//
//  SettingsView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 22/03/22.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.openURL) var openURL
    @EnvironmentObject var store: SettingsStore
    @State private var email = SupportEmail()
    @State private var showPolicy: Bool = false
    @Binding var showSettings: Bool
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker(selection: $store.gesture) {
                        Text("Mark as Favorite").tag(DoubleTapGesture.favorite)
                        Text("Mark as Watched").tag(DoubleTapGesture.watched)
                    } label: {
                        Label("Double Tap Gesture", systemImage: "hand.tap")
                    }
                    .pickerStyle(.inline)
                } header: {
                    Text("Gesture")
                } footer: {
                    Text("The function is performed when double-tap the cover image.")
                }
                Section(header: Text("Support")) {
                    Button( action: {
                        email.send(openURL: openURL)
                    }, label: {
                        Label("Send email", systemImage: "envelope")
                    })
                    Button(action: {
                        showPolicy.toggle()
                    }, label: {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    })
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
    @StateObject private static var store = SettingsStore()
    @State private static var showSettings = false
    static var previews: some View {
        SettingsView(showSettings: $showSettings)
            .environmentObject(store)
    }
}
