//
//  AcknowledgementsSettings.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 20/12/22.
//

import SwiftUI

struct AboutSettings: View {
    @StateObject private var settings = SettingsStore.shared
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    let buildNumber: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    var body: some View {
        Form {
            Section {
                HStack(alignment: .center) {
                    VStack {
                        Image("Cronica")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100, alignment: .center)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
                            .onTapGesture(count: 3) {
                                settings.displayDeveloperSettings.toggle()
                            }
                        Text("An Egger & Co Product")
                            .fontWeight(.semibold)
                            .fontDesign(.monospaced)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .padding(.top)
                    }
                    .padding(.zero)
                }
                .frame(maxWidth: .infinity)
                .padding(.zero)
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            
#if !os(tvOS)
            Section {
                
                Button("Review on the App Store") {
                    guard let writeReviewURL = URL(string: "https://apps.apple.com/app/1614950275?action=write-review") else { return }
#if os(macOS)
                    NSWorkspace.shared.open(writeReviewURL)
#else
                    UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
#endif
                }
#if os(macOS)
                .buttonStyle(.link)
#endif
                
                
                aboutButton(title: NSLocalizedString("X/Twitter", comment: ""),
                            url: "https://x.com/CronicaApp")
                
                if let appUrl = URL(string: "https://apple.co/3TV9SLP") {
                    ShareLink(item: appUrl)
                        .labelStyle(.titleOnly)
#if os(macOS)
                        .buttonStyle(.link)
#endif
                }
            }
#endif
#if os(macOS)
            privacy
#endif
            
            Section("Content Provider") {
                aboutButton(
                    title: "The Movie Database",
                    url: "https://www.themoviedb.org"
                )
            }
            
            Section("Design") {
                aboutButton(
                    title: NSLocalizedString("Icon Designer", comment: ""),
                    subtitle: "Akhmad",
                    url: "https://www.fiverr.com/akhmad437"
                )
            }
            
            Section("Translation") {
                aboutButton(title: String(localized: "German"),
                            subtitle: "Simon Boer",
                            url: "https://twitter.com/SimonBoer29")
                aboutButton(title: String(localized: "Spanish"),
                            subtitle: "Luis Felipe Lerma Alvarez",
                            url: "https://www.instagram.com/lerma_alvarez")
                aboutButton(title: String(localized: "Slovak"),
                            subtitle: "Tomáš Švec", url: "mailto:svec.tomas@gmail.com")
                aboutButton(title: String(localized: "French"),
                            subtitle: "Pierre Quéré", url: "")
                aboutButton(title: String(localized: "Italian"),
                            subtitle: "Kevin Manca", url: "http://github.com/kevinm6")
            }
            
            Section("Libraries") {
                aboutButton(
                    title: "Nuke",
                    url: "https://github.com/kean/Nuke"
                )
                aboutButton(
                    title: "Aptabase",
                    url: "https://aptabase.com"
                )
                aboutButton(title: "YouTubePlayerKit",
                            url: "https://github.com/SvenTiigi/YouTubePlayerKit")
            }
            
            Section {
                aboutButton(
                    title: "GitHub",
                    url: "https://github.com/egger/cronica"
                )
            } header: {
                Text("Source Code")
            } footer: {
                Text("Cronica is open-source, you can contribute to the project.")
            }
            
            Section {
                if settings.displayDeveloperSettings {
                    NavigationLink("🛠️", value: SettingsScreens.developer)
                }
                CenterHorizontalView {
                    Text("Version \(appVersion ?? "") • \(buildNumber)")
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                }
            }
            .listRowBackground(Color.clear)
        }
        .navigationTitle("About")
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
            buttonLabels(title: title, subtitle: subtitle)
        }
#if os(macOS)
        .buttonStyle(.link)
#endif
    }
    
    private func buttonLabels(title: String, subtitle: String?) -> some View {
        VStack(alignment: .leading) {
            Text(title)
            if let subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
#if os(macOS)
    private var privacy: some View {
        Section {
            Button("Privacy Policy") {
                guard let url = URL(string: "https://app.oncronica.com/privacy") else { return }
                NSWorkspace.shared.open(url)
            }
            .buttonStyle(.link)
        } header: {
            Text("Privacy")
        }
    }
#endif
}

#Preview {
    AboutSettings()
}
