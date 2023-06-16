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
    // Lists
    @State private var listManager = ExternalWatchlistManager.shared
    @State private var lists = [TMDBListResult]()
    @State private var isLoading = true
    @State private var selectedList: TMDBListResult?
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
                await load()
            }
            if userIsLoggedIn {
                Section("Lists") {
                    if isLoading {
                        loadingSection
                    } else {
                        listsSection
                    }
                }
                
                Section("Watchlist") {
                    if isFetching {
                        CenterHorizontalView { ProgressView() }
                    } else {
                        TMDBWatchlistView()
                    }
                }
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
    
    
    // Lists
    private func load() async {
        let fetchedLists = await listManager.fetchLists()
        if let result = fetchedLists?.results {
            lists = result
            withAnimation { self.isLoading = false }
        }
    }
    
    private var loadingSection: some View {
        Section {
            CenterHorizontalView { ProgressView("Loading") }
        }
    }
    
    private var listsSection: some View {
        Section {
            List {
                if lists.isEmpty {
                    CenterHorizontalView {
                        Text("emptyLists")
                            .foregroundColor(.secondary)
                    }
                } else {
                    ForEach(lists) { list in
                        Button(list.itemTitle) {
                            selectedList = list
                        }
                    }
                }
            }
        }
        .sheet(item: $selectedList) { list in
            NavigationStack {
                TMDBListDetails(list: list)
                    .toolbar {
                        Button("Done") { selectedList = nil }
                    }
            }
        }
    }
}

struct AccountSettings_Previews: PreviewProvider {
    static var previews: some View {
        TMDBAccountView()
    }
}
