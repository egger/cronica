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
    private var tmdbAccount = TMDBAccountManager.shared
    @State private var hasAccess = false
    @State private var showSignOutConfirmation = false
    var body: some View {
        Section {
            tmdbAccountButton
            if hasAccess {
                NavigationLink(destination: EmptyView()) {
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
