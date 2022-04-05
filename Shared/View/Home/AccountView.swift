//
//  AccountView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 22/03/22.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.openURL) var openURL
    @State private var email = SupportEmail()
    var body: some View {
        Form {
            Section(header: Text("Account (Coming Soon)"), footer: Text("Log in with your TMDB Account to sync watchlist, and recommendations.")) {
                switch settings.isUserLogged {
                case true:
                    VStack {
                        Button("Log off", role: .destructive) {
                            
                        }
                    }
                case false:
                    Button {
                        
                    } label: {
                        Label("Log In", systemImage: "person.crop.circle")
                    }
                }
            }
            .disabled(true)
            Section(header: Text("Support")) {
                Button( action: {
                    email.send(openURL: openURL)
                }, label: { Text("Send email") })
                Link("Privacy Policy", destination: URL(string: "https://alexandremadeira.dev/cronica/privacy")!)
            }
            HStack {
                Spacer()
                Text("Made in Brazil 🇧🇷")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
