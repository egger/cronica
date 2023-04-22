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
    @State private var isImporting = false
    var body: some View {
        Section {
            tmdbAccountButton
            if hasAccess {
                NavigationLink(destination: TMDBListsView(viewModel: $tmdbAccount)) {
                    Text("tmdbAccountListsManager")
                }
                importWatchlist
            }
            
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
        Button {
            Task {
                withAnimation { self.isImporting = true }
                let movies = await tmdbAccount.fetchWatchlist(type: .movie)
                let shows = await tmdbAccount.fetchWatchlist(type: .tvShow)
                guard let moviesResult = movies?.results, let showsResult = shows?.results else { return }
                let result = moviesResult + showsResult
                for item in result {
                    PersistenceController.shared.save(item)
                }
                withAnimation { self.isImporting = false }
            }
        } label: {
            if isImporting {
               ProgressView()
            } else {
                Text("importTMDBWatchlist")
            }
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
