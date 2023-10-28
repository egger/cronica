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
#if !os(tvOS)
            if let appUrl = URL(string: "https://apple.co/3TV9SLP") {
                ShareLink(item: appUrl).labelStyle(.titleOnly)
#if os(macOS)
                    .buttonStyle(.link)
#endif
            }
#endif
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
                aboutButton(title: "German", subtitle: "Simon Boer", url: "https://twitter.com/SimonBoer29")
                aboutButton(title: "Spanish", subtitle: "Luis Felipe Lerma Alvarez",
							url: "https://www.instagram.com/lerma_alvarez")
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
                aboutButton(title: "YouTubePlayerKit", url: "https://github.com/SvenTiigi/YouTubePlayerKit")
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
                if settings.displayDeveloperSettings {
                    NavigationLink("🛠️", value: SettingsScreens.developer)
                }
                CenterHorizontalView {
                    Text("Version \(appVersion ?? "") • \(buildNumber)")
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .onTapGesture(count: 3) {
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

#Preview {
    AboutSettings()
}
