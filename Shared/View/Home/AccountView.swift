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
    @State private var email = SupportEmail(
        toAddress: "contact@alexandremadeira.dev",
        subject: "Support Email (Cronica App)",
        messageHeader: "Please describe your issue below")
    var body: some View {
        Form {
            Section(header: Text("Account"), footer: Text("Log in with your TMDB Account to sync watchlist, and recommendations.")) {
                Button {
                    
                } label: {
                    Label("Log In", systemImage: "person.crop.circle")
                }
                if settings.isUserLogged {
                    Button("Log off", role: .destructive) {
                        
                    }
                }
            }
            Section(header: Text("Notifications")) {
                NavigationLink(destination: UpcomingNotificationsView()) {
                    Text("Upcoming notifications")
                }
            }
            Section(header: Text("Support")) {
                Button( action: {
                    email.send(openURL: openURL)
                }, label: {
                    Label("Send email", systemImage: "envelope.badge")
                })
                Button {
                    
                } label: {
                    Label("Privacy Policy", systemImage: "hand.raised")
                }
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

private struct UpcomingNotificationsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.id, ascending: true)],
        animation: .default)
    private var notificationItems: FetchedResults<WatchlistItem>
    var body: some View {
        ScrollView {
            ForEach(notificationItems.filter { $0.notify == true }) { item in
                Text(item.itemTitle)
            }
            .navigationTitle("Upcoming Notifications")
        }
    }
}

