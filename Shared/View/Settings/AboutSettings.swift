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
#if os(macOS)
                    .buttonStyle(.link)
#endif
            }
            
#if os(macOS)
            privacy
#endif
            
            FeedbackSettingsView()
            
            Section("Design") {
                aboutButton(
                    title: "acknowledgmentsAppIconTitle",
                    subtitle: "acknowledgmentsAppIconSubtitle",
                    url: "https://www.fiverr.com/akhmad437"
                )
            }
            
            Section("Translation") {
                aboutButton(title: "German", subtitle: "Simon Boer", url: "https://twitter.com/simonboer16")
            }
            
            Section("Libraries") {
                aboutButton(
                    title: "acknowledgmentsSDWebImage",
                    url: "https://github.com/SDWebImage/SDWebImageSwiftUI"
                )
                aboutButton(
                    title: "TelemetryDeck",
                    url: "https://telemetrydeck.com/"
                )
            }
            
            Section("acknowledgmentsContentProviderTitle") {
                aboutButton(
                    title: "acknowledgmentsContentProviderSubtitle",
                    url: "https://www.themoviedb.org"
                )
            }
            
            Section("Source Code") {
                aboutButton(
                    title: "cronicaGitHub",
                    url: "https://github.com/MadeiraAlexandre/Cronica"
                )
            }
            
            Section {
                CenterHorizontalView { AttributionView() }
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
    
    private func aboutButton(title: String, subtitle: String? = nil, url: String) -> some View {
        Button {
            guard let url = URL(string: url) else { return }
#if os(macOS)
            NSWorkspace.shared.open(url)
#else
            UIApplication.shared.open(url)
#endif
        } label: {
            InformationalLabel(title: title, subtitle: subtitle)
        }
#if os(macOS)
        .buttonStyle(.link)
#endif
    }
    
#if os(macOS)
    private var privacy: some View {
        Section {
            Button("settingsPrivacyPolicy") {
                guard let url = URL(string: "https://alexandremadeira.dev/cronica/privacy") else { return }
                NSWorkspace.shared.open(url)
            }
            .buttonStyle(.link)
        } header: {
            Label("Privacy", systemImage: "hand.raised")
        }
    }
#endif
}

struct AboutSettings_Previews: PreviewProvider {
    static var previews: some View {
        AboutSettings()
    }
}
#endif
