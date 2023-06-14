//
//  AcknowledgementsSettings.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 20/12/22.
//

import SwiftUI
#if os(iOS) || os(macOS)
struct AboutSettings: View {
#if os(iOS)
    @Environment(\.requestReview) var requestReview
#endif
    @StateObject private var settings = SettingsStore.shared
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    var body: some View {
        Form {
            Section {
                CenterHorizontalView {
                    VStack {
                        Image("Cronica")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120, alignment: .center)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(radius: 5)
                        Text("Developed by Alexandre Madeira")
                            .fontWeight(.semibold)
                            .fontDesign(.monospaced)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .padding(.top)
                    }
                }
            }
            
#if os(iOS)
            Button {
                requestReview()
            } label: {
                Text("settingsReviewCronica")
            }
#endif
            
            if let appUrl = URL(string: "https://apple.co/3TV9SLP") {
                ShareLink(item: appUrl).labelStyle(.titleOnly)
            }
            
#if os(macOS)
            privacy 
#endif
            
            FeedbackSettingsView()
            
            Section("Design") {
                Button {
                    openUrl("https://www.fiverr.com/akhmad437")
                } label: {
                    InformationalLabel(title: "acknowledgmentsAppIconTitle",
                                       subtitle: "acknowledgmentsAppIconSubtitle")
                }
            }
            
            Section("Translation") {
                Button {
                    openUrl("https://twitter.com/simonboer16")
                } label: {
                    InformationalLabel(title: "German",
                                       subtitle: "Simon Boer")
                }
            }
            
            Section("Libraries") {
                Button {
                    openUrl("https://github.com/SDWebImage/SDWebImageSwiftUI")
                } label: {
                    InformationalLabel(title: "acknowledgmentsSDWebImage")
                }
                
                Button {
                    openUrl("https://telemetrydeck.com/")
                } label: {
                    InformationalLabel(title: "TelemetryDeck")
                }
            }
            
            Section("acknowledgmentsContentProviderTitle") {
                Button {
                    openUrl("https://www.themoviedb.org")
                } label: {
                    InformationalLabel(title: "acknowledgmentsContentProviderSubtitle")
                }
            }
            
            Section("Source Code") {
                Button {
                    openUrl("https://github.com/MadeiraAlexandre/Cronica")
                } label: {
                    InformationalLabel(title: "cronicaGitHub")
                }
                
            }
            
            Section {
                if settings.displayDeveloperSettings {
                    NavigationLink(value: SettingsScreens.developer) {
                        SettingsLabelWithIcon(title: "Developer Options", icon: "hammer", color: .purple)
                    }
                }
                CenterHorizontalView {
                    Text("Version \(appVersion ?? "")")
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .onTapGesture(count: 2) {
                            withAnimation { settings.displayDeveloperSettings.toggle() }
                        }
                }
            }
        }
        .navigationTitle("aboutTitle")
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
    
#if os(macOS)
    private var privacy: some View {
        Section {
            Button("settingsPrivacyPolicy") {
                guard let url = URL(string: "https://alexandremadeira.dev/cronica/privacy") else { return }
                NSWorkspace.shared.open(url)
            }
        } header: {
            Label("Privacy", systemImage: "hand.raised")
        }
    }
#endif
    
    private func openUrl(_ url: String) {
        guard let url = URL(string: url) else { return }
#if os(macOS)
        NSWorkspace.shared.open(url)
#else
        UIApplication.shared.open(url)
#endif
    }
}

struct AboutSettings_Previews: PreviewProvider {
    static var previews: some View {
        AboutSettings()
    }
}
#endif
