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
    @State private var viewModel = AccountManager.shared
    @State private var showSignOutConfirmation = false
    @State private var isFetching = false
    @State var userIsLoggedIn = false
    var body: some View {
        Section {
            if isFetching {
                CenterHorizontalView { ProgressView() }
            } else {
                if userIsLoggedIn {
                    NavigationLink("AccountSettingsViewListsManager", destination: TMDBListsView())
                    NavigationLink("AccountSettingsViewWatchlist", destination: TMDBWatchlistView())
                }
                accountButton
            }
        } header: {
            userIsLoggedIn ? Text("AccountSettingsViewHeaderSignIn") : Text("AccountSettingsViewFooterHeader")
        } footer: {
#if os(iOS)
            if !userIsLoggedIn { Text("AccountSettingsViewFooter") }
#endif
        }
        .alert("removeTMDBAccount", isPresented: $showSignOutConfirmation) {
            Button("Confirm", role: .destructive) {
                Task {
                    withAnimation { self.userIsLoggedIn = false }
                    await viewModel.logOut()
                }
            }
        }
        .task {
            withAnimation { userIsLoggedIn = viewModel.checkAccessStatus() }
        }
    }
    
    private var accountButton: some View {
        Button(role: userIsLoggedIn ? .destructive : nil) {
            userIsLoggedIn ? SignOut() : SignIn()
        } label: {
            Text(userIsLoggedIn ? "AccountSettingsViewSignOut" : "AccountSettingsViewSignIn")
                .tint(userIsLoggedIn ? .red : nil)
        }
    }
    
    private func SignIn() {
        Task {
            do {
                DispatchQueue.main.async { withAnimation { self.isFetching = true } }
                let url = await viewModel.requestToken()
                guard let url else { return }
                let _ = try await webAuthenticationSession.authenticate(using: url,
                                                                        callbackURLScheme: "cronica",
                                                                        preferredBrowserSession: .shared)
                try await viewModel.requestAccess()
                await viewModel.createV3Session()
                DispatchQueue.main.async { withAnimation { self.isFetching = false } }
                DispatchQueue.main.async { withAnimation { self.userIsLoggedIn = true } }
            } catch {
                if Task.isCancelled { return }
                CronicaTelemetry.shared.handleMessage("Failed to SignIn", for: "AccountSettings.failed")
                DispatchQueue.main.async { withAnimation { self.isFetching = false } }
            }
        }
    }
    
    private func SignOut() { showSignOutConfirmation.toggle() }
}

@available(iOS 16.4, *)
@available(macOS 13.3, *)
@available(tvOS 16.4, *)
struct AccountSettings_Previews: PreviewProvider {
    static var previews: some View {
        AccountSettingsView()
    }
}
