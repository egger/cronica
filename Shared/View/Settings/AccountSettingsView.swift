//
//  AccountSettingsView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 21/04/23.
//

import SwiftUI
import AuthenticationServices
import Foundation
import Security

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
            tmdbAccountButton
            if hasAccess {
                NavigationLink(destination: TMDBListsView(viewModel: $tmdbAccount)) {
                    Text("tmdbAccountListsManager")
                }
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

final class KeychainHelper {
    static let standard = KeychainHelper()
    private init() { }
    
    func save(_ data: Data, service: String, account: String) {
        let query = [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
        ] as [CFString : Any] as CFDictionary
        
        let status = SecItemAdd(query, nil)
        
        if status != errSecSuccess {
            CronicaTelemetry.shared.handleMessage("\(status)", for: "KeychainHelper.save")
        }
    }
    
    func read(service: String, account: String) -> Data? {
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ] as [CFString : Any] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        
        return (result as? Data)
    }
    
    func delete(service: String, account: String) {
        
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
        ] as [CFString : Any] as CFDictionary
        
        // Delete item from keychain
        SecItemDelete(query)
    }
}

struct TMDBListsView: View {
    @Binding var viewModel: TMDBAccountManager
    @State private var lists = [TMDBListResult]()
    var body: some View {
        VStack {
            List {
                ForEach(lists) { list in
                    NavigationLink(destination: TMDBListDetails(list: list, viewModel: $viewModel)) {
                        Text(list.itemTitle)
                    }
                }
            }
        }
        .navigationTitle("tmdbLists")
        .onAppear {
            if lists.isEmpty {
                Task {
                    let fetchedLists = await viewModel.fetchLists()
                    if let result = fetchedLists?.results {
                        lists = result
                    }
                }
            }
        }
    }
}

struct TMDBListDetails: View {
    let list: TMDBListResult
    @Binding var viewModel: TMDBAccountManager
    @State private var syncList = false
    @State private var detailedList: DetailedTMDBList?
    @State private var items = [ItemContent]()
    @State private var isLoading = true
    var body: some View {
        Form {
            Section {
                Toggle("syncTMDBList", isOn: $syncList)
                if syncList {
                    Button("chooseLocalList") {
                        
                    }
                }
                Button("importList") {
                    
                }
            } header: {
                Text("tmdbListSyncConfig")
            }
            
            if isLoading {
                ProgressView()
            } else {
                Section {
                    if items.isEmpty {
                        Text("emptyList")
                    } else {
                        ForEach(items) { item in
#if os(iOS)
                            NavigationLink(destination: ItemContentDetails(title: item.itemTitle,
                                                                           id: item.id,
                                                                           type: item.itemContentMedia)) {
                                Text(item.itemTitle)
                            }
#else
                            Text(item.itemTitle)
#endif
                        }
                    }
                }
            }
        }
        .navigationTitle(list.itemTitle)
        .onAppear {
            Task {
                detailedList = await viewModel.fetchList(id: list.id)
                if !items.isEmpty { return }
                if let content = detailedList?.results {
                    items = content
                }
                isLoading = false
            }
        }
    }
}
