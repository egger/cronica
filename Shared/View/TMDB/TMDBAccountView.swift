//
//  TMDBAccountView.swift
//  Cronica (iOS)
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
        Section {
            accountButton
                .alert("removeTMDBAccount", isPresented: $showSignOutConfirmation) {
                    Button("Confirm", role: .destructive) {
                        Task {
                            withAnimation { self.userIsLoggedIn = false }
                            await viewModel.logOut()
                        }
                    }
                }
        } header: {
            Text("connectedAccounts")
        } footer: {
            Text("tmdbSyncFeatures")
        }
        .task {
            withAnimation { userIsLoggedIn = viewModel.checkAccessStatus() }
        }
    }
    
    private var accountButton: some View {
        Button(role: userIsLoggedIn ? .destructive : nil) {
            Task {
                userIsLoggedIn ? SignOut() : await SignIn()
            }
        } label: {
			accountLabel(title: "connectedAccountTMDB",
                               subtitle: userIsLoggedIn ? "AccountSettingsViewSignOut" : "AccountSettingsViewSignIn",
                               image: userIsLoggedIn ? "person.crop.circle.fill.badge.minus" : "person.crop.circle.badge.plus")
                .tint(userIsLoggedIn ? .red : nil)
#if os(macOS)
                .foregroundColor(userIsLoggedIn ? .red : nil)
#endif
        }
    }
	
	private func accountLabel(title: String, subtitle: String, image: String) -> some View {
		HStack {
			VStack {
				Image(systemName: image)
			}
			VStack(alignment: .leading) {
				Text(NSLocalizedString(title, comment: ""))
				Text(NSLocalizedString(subtitle, comment: ""))
					.font(.caption)
					.foregroundColor(.secondary)
			}
		}
	}
    
    @MainActor
    private func SignIn() async {
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
    
    private func SignOut() { showSignOutConfirmation.toggle() }
}

#Preview {
    TMDBAccountView()
}
