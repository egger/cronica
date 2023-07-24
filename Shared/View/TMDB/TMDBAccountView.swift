//
//  TMDBAccountView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 21/04/23.
//

import SwiftUI
import AuthenticationServices

struct TMDBAccountView: View {
    @Environment(\.webAuthenticationSession) private var webAuthenticationSession
    @State private var viewModel = AccountManager.shared
    @State private var showSignOutConfirmation = false
    @State private var isFetching = false
    @State var userIsLoggedIn = false
    var body: some View {
        Form {
            Section("Account") {
                accountButton
                    .alert("removeTMDBAccount", isPresented: $showSignOutConfirmation) {
                        Button("Confirm", role: .destructive) {
                            Task {
                                withAnimation { self.userIsLoggedIn = false }
                                await viewModel.logOut()
                            }
                        }
                    }
            }
            .task {
                withAnimation { userIsLoggedIn = viewModel.checkAccessStatus() }
            }
        }
        .navigationTitle("connectedAccountTMDB")
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
    
    private var accountButton: some View {
        Button(role: userIsLoggedIn ? .destructive : nil) {
            userIsLoggedIn ? SignOut() : SignIn()
        } label: {
            Text(userIsLoggedIn ? "AccountSettingsViewSignOut" : "AccountSettingsViewSignIn")
                .tint(userIsLoggedIn ? .red : nil)
#if os(macOS)
                .foregroundColor(userIsLoggedIn ? .red : nil)
#endif
        }
    }
    
    private func SignIn() {
        Task {
            do {
                await MainActor.run { withAnimation { self.isFetching = true } }
                let url = await viewModel.requestToken()
                guard let url else { return }
                let _ = try await webAuthenticationSession.authenticate(using: url,
                                                                        callbackURLScheme: "cronica",
                                                                        preferredBrowserSession: .shared)
                try await viewModel.requestAccess()
                await viewModel.createV3Session()
                await MainActor.run { withAnimation { self.isFetching = false } }
                await MainActor.run { withAnimation { self.userIsLoggedIn = true } }
            } catch {
                if Task.isCancelled { return }
                CronicaTelemetry.shared.handleMessage("Failed to SignIn", for: "AccountSettings.failed")
                await MainActor.run { withAnimation { self.isFetching = false } }
            }
        }
    }
    
    private func SignOut() { showSignOutConfirmation.toggle() }
}

struct AccountSettings_Previews: PreviewProvider {
    static var previews: some View {
        TMDBAccountView()
    }
}
