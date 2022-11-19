//
//  SettingsView.swift
//  CronicaMac
//
//  Created by Alexandre Madeira on 02/11/22.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            WatchlistSettings()
                .tabItem {
                    Label("Watchlist", systemImage: "square.stack")
                }
            PrivacySettings()
                .tabItem {
                    Label("Privacy", systemImage: "hand.raised.fingers.spread")
                }
            SupportSettingsTab()
                .tabItem {
                    Label("Support", systemImage: "questionmark.circle")
                }
#if DEBUG
            DeveloperView()
                .tabItem {
                    Label("Developer", systemImage: "curlybraces")
                }
#endif
        }
        .frame(width: 450, height: 350)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

private struct SupportSettingsTab: View {
    var body: some View {
        FeedbackSettingsView()
    }
}

private struct PrivacySettings: View {
    @AppStorage("disableTelemetry") private var disableTelemetry = false
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Disable Telemetry", isOn: $disableTelemetry)
                    NavigationLink("Privacy Policy",
                                   destination: PrivacyPolicySettings())
                    Button("Privacy Policy") {
                        NSWorkspace.shared.open(URL(string: "https://alexandremadeira.dev/cronica/privacy")!)
                    }
                    .buttonStyle(.link)
                } header: {
                    Label("Privacy", systemImage: "hand.raised.fingers.spread")
                } footer: {
                    Text("privacyfooter")
                        .padding(.bottom)
                }
            }
            .formStyle(.grouped)
        }
    }
}

private struct WatchlistSettings: View {
    @State private var updatingItems = false
    var body: some View {
        Form {
            Section {
                Button(action: {
                    updateItems()
                }, label: {
                    if updatingItems {
                        Text("Updating, please wait.")
                    } else {
                        Text("Update Items")
                    }
                })
                .buttonStyle(.link)
            } header: {
                Label("Sync", systemImage: "arrow.2.circlepath")
            } footer: {
                HStack {
                    Text("This will update your items with new information available on TMDb, if available.")
                    Spacer()
                }
            }
        }
        .formStyle(.grouped)
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
