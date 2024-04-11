//
//  AcknowledgementsSettings.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 20/12/22.
//

import SwiftUI

struct AboutSettings: View {
#if os(iOS)
    @Environment(\.requestReview) var requestReview
#endif
    @StateObject private var settings = SettingsStore.shared
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
	let buildNumber: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    var body: some View {
        Form {
            Section {
                CenterHorizontalView {
                    VStack {
                        Image("Cronica")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100, alignment: .center)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(radius: 5)
                            .onTapGesture(count: 4) {
                                withAnimation { settings.displayDeveloperSettings.toggle() }
                            }
                    }
                }
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
#if os(iOS)
            Button {
                requestReview()
            } label: {
                Text("Review on the App Store")
            }
#endif
            
#if !os(tvOS)
            Section {
                aboutButton(title: NSLocalizedString("X/Twitter", comment: ""),
                            url: "https://x.com/CronicaApp")
            }
#endif
            
            
#if os(iOS)
            if let appUrl = URL(string: "https://apple.co/3TV9SLP") {
                ShareLink(item: appUrl).labelStyle(.titleOnly)
            }
#endif
#if os(macOS)
            privacy
#endif
            
            Section("Content Provider") {
                aboutButton(
                    title: NSLocalizedString("The Movie Database", comment: ""),
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
            }
            
            Section("Libraries") {
                aboutButton(
                    title: NSLocalizedString("Nuke", comment: ""),
                    url: "https://github.com/kean/Nuke"
                )
                aboutButton(
                    title: "Aptabase",
                    url: "https://aptabase.com"
                )
                aboutButton(title: NSLocalizedString("YouTubePlayerKit", comment: ""),
                            url: "https://github.com/SvenTiigi/YouTubePlayerKit")
            }
            
            Section {
                aboutButton(
                    title: NSLocalizedString("GitHub", comment: ""),
                    url: "https://github.com/MadeiraAlexandre/Cronica"
                )
            } header: {
                Text("Source Code")
            } footer: {
                Text("Cronica is open-source, you can contribute to the project.")
            }
            
            Section("Developers") {
                aboutButton(title: "Alexandre Madeira", url: "https://alexandremadeira.dev")
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
			Text(NSLocalizedString(title, comment: ""))
			if let subtitle {
				Text(NSLocalizedString(subtitle, comment: ""))
					.font(.caption)
					.foregroundColor(.secondary)
			}
		}
	}
    
#if os(macOS)
    private var privacy: some View {
        Section {
            Button("Privacy Policy") {
                guard let url = URL(string: "https://alexandremadeira.dev/cronica/privacy") else { return }
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
