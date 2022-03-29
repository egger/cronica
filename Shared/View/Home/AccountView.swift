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
            Section(header: Text("Notifications")) {
                NavigationLink(destination: UpcomingNotificationsView()) {
                    Text("Upcoming notifications")
                }
            }
            Section(header: Text("Support")) {
                Button( action: {
                    email.send(openURL: openURL)
                }, label: { Text("Send email") })
                Link("Privacy Policy", destination: URL(string: "https://alexandremadeira.dev")!)
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

