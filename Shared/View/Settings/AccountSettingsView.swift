//
//  AccountSettingsView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 21/04/23.
//

import SwiftUI
import AuthenticationServices

@available(iOS 16.4, *)
@available(tvOS 16.4, *)
@available(macOS 13.3, *)
struct AccountSettingsView: View {
    @Environment(\.webAuthenticationSession) private var webAuthenticationSession
    @State private var tmdbAccount = TMDBAccountManager.shared
    @State private var hasAccess = false
    @State private var showSignOutConfirmation = false
    var body: some View {
        Section {
            if hasAccess {
                NavigationLink(destination: TMDBListsView(viewModel: $tmdbAccount)) {
                    Text("tmdbAccountListsManager")
                }
                importWatchlist
            }
            tmdbAccountButton
            
        } header: {
            hasAccess ? Text("tmdbAccountHeaderSignedIn") : Text("tmdbAccountHeader")
        } footer: {
            if !hasAccess {
                Text("tmdbAccountFooter")
            }
        }
        .alert("removeTMDBAccount", isPresented: $showSignOutConfirmation) {
            Button("Confirm", role: .destructive) {
                tmdbAccount.removeUserAccess()
                hasAccess = false
            }
        }
    }
    
    private var tmdbAccountButton: some View {
        Button {
            hasAccess ? SignOut() : SignIn()
        } label: {
            Text(hasAccess ? "tmdbAccountButtonSignOut" : "tmdbAccountButtonSignIn")
                .tint(hasAccess ? .red : nil)
        }
        .task {
            hasAccess = tmdbAccount.checkAccessStatus()
        }
    }
    
    private var importWatchlist: some View {
        NavigationLink(destination: TMDBWatchlistView(viewModel: $tmdbAccount)) {
            Text("watchlistTMDB")
        }
    }
    
    private func SignIn() {
        Task {
            let url = await tmdbAccount.requestToken()
            guard let url else { return }
            let _ = try await webAuthenticationSession.authenticate(using: url,
                                                                    callbackURLScheme: "cronica",
                                                                    preferredBrowserSession: .shared)
            await tmdbAccount.requestAccess()
            hasAccess.toggle()
        }
    }
    
    private func SignOut() {
        showSignOutConfirmation.toggle()
    }
}

@available(iOS 16.4, *)
@available(macOS 13.3, *)
@available(tvOS 16.4, *)
struct AccountSettings_Previews: PreviewProvider {
    static var previews: some View {
        AccountSettingsView()
    }
}

struct TMDBWatchlistView: View {
    @State private var isImporting = false
    @Binding var viewModel: TMDBAccountManager
    @State private var settings = SettingsStore.shared
    @State private var items = [ItemContent]()
    @State private var hasLoaded = false
    var body: some View {
        Form {
            if !hasLoaded {
                CenterHorizontalView { ProgressView("Loading") }
            } else {
                if !settings.userImportedTMDB {
                    Section {
                        importButton
                    }
                } else {
                    Section {
                        syncButton
                    }
                }
                
                Section {
                    if items.isEmpty {
                        CenterHorizontalView { Text("emptyList") }
                    } else {
                        ForEach(items) { item in
                            ItemContentRow(item: item)
                        }
                    }
                } header: {
                    Text("itemsTMDB")
                }
                
            }
        }
        .navigationTitle("watchlistTMDB")
        .task {
            await load()
        }
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
    
    private func load() async {
        if hasLoaded { return }
        let movies = await viewModel.fetchWatchlist(type: .movie)
        let shows = await viewModel.fetchWatchlist(type: .tvShow)
        guard let moviesResult = movies?.results, let showsResult = shows?.results else { return }
        let result = moviesResult + showsResult
        items = result
        withAnimation { self.hasLoaded = true }
    }
    
    private var importButton: some View {
        Button {
            Task {
                withAnimation { self.isImporting = true }
                for item in items {
                    PersistenceController.shared.save(item)
                }
                withAnimation { self.isImporting = false }
                settings.userImportedTMDB = true
            }
        } label: {
            if isImporting {
               ProgressView()
            } else {
                Text("importTMDBWatchlist")
            }
        }
    }
    
    private var syncButton: some View {
        Button {
            
        } label: {
            Text("syncNow")
        }
    }
}
