//
//  HomeView.swift
//  Story
//
//  Created by Alexandre Madeira on 10/02/22.
//

import SwiftUI

struct HomeView: View {
    static let tag: String? = "Home"
    @StateObject private var viewModel = HomeViewModel()
    @State private var showAccount: Bool = false
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    HomeListItemsView()
                    ForEach(viewModel.moviesSections) {
                        ContentListView(style: $0.style, type: MediaType.movie, title: $0.title, items: $0.results)
                    }
                    ForEach(viewModel.tvSections) {
                        ContentListView(style: $0.style, type: MediaType.tvShow, title: $0.title, items: $0.results)
                    }
                    AttributionView()
                }
                .navigationTitle("Home")
                .toolbar {
                    ToolbarItem {
                        Button {
                            showAccount.toggle()
                        } label: {
                            Label("Account", systemImage: "person.crop.circle")
                        }
                    }
                }
#if os(iOS)
                .navigationViewStyle(.stack)
#endif
                .sheet(isPresented: $showAccount) {
                    NavigationView {
                        AccountFormView()
                            .environmentObject(SettingsStore())
                            .navigationTitle("Account")
#if os(iOS)
                            .navigationBarTitleDisplayMode(.inline)
#endif
                            .toolbar {
                                ToolbarItem {
                                    Button("Done") {
                                        showAccount.toggle()
                                    }
                                }
                            }
                    }
                }
                .task {
                    load()
                }
            }
        }
        
    }
    
    @Sendable
    private func load() {
        Task {
            await viewModel.loadSections()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

private struct AccountFormView: View {
    @State private var easterEgg: Bool = false
    @State private var userAdded: Bool = false
    @State private var automaticallyNotify = false
    @EnvironmentObject var settings: SettingsStore
    var body: some View {
        Form {
            Section(header: Text("Account"), footer: Text("Log in with your TMDB Account to sync watchlist, and recommendations.")) {
                Button {
                    
                } label: {
                    Label("Log In", systemImage: "person.crop.circle")
                }
                if userAdded {
                    Button("Log off", role: .destructive) {
                        
                    }
                }
            }
            Section(header: Text("Settings")) {
                Toggle(isOn: $settings.isAutomaticallyNotification) {
                    Label("Notify Automatically", systemImage: "bell.square")
                }
            }
            Section(header: Text("Support"), footer: Text("App Version:")) {
                Button {
                    
                } label: {
                    Label("Send email", systemImage: "envelope.badge")
                }
                Button {
                    
                } label: {
                    Label("Privacy Policy", systemImage: "hand.raised")
                }
            }
            HStack {
                Spacer()
                Text(easterEgg ? "🇧🇷" : "Made in Brazil")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .onTapGesture {
                        easterEgg.toggle()
                    }
                Spacer()
            }
        }
    }
}
