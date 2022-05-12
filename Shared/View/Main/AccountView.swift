//
//  AccountView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 22/03/22.
//

import SwiftUI

struct AccountView: View {
    @Environment(\.openURL) var openURL
    @EnvironmentObject var store: SettingsStore
    @State private var email = SupportEmail()
    @State private var showPolicy: Bool = false
    var body: some View {
        Form {
            Section {
                Picker(selection: $store.gesture) {
                    Text("Mark as Favorite").tag(DoubleTapGesture.favorite)
                    Text("Mark as Watched").tag(DoubleTapGesture.watched)
                } label: {
                    Label("Gesture", systemImage: "hand.tap")
                }
                .pickerStyle(.inline)
            } header: {
                Text("Double Tap Gesture")
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
                    .foregroundColor(.secondary)
                Spacer()
            }
            .fullScreenCover(isPresented: $showPolicy) {
                SFSafariViewWrapper(url: URL(string: "https://cronica.alexandremadeira.dev/privacy")!)
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
