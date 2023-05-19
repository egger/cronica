//
//  AcknowledgementsSettings.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 20/12/22.
//

import SwiftUI

struct AcknowledgementsSettings: View {
    @State private var animateEasterEgg = false
    @StateObject private var settings = SettingsStore.shared
    var body: some View {
        Form {
            Section {
                Button {
                    openUrl(URL(string: "https://www.fiverr.com/akhmad437")!)
                } label: {
                    InformationalLabel(title: "acknowledgmentsAppIconTitle",
                                       subtitle: "acknowledgmentsAppIconSubtitle")
                }
#if os(macOS)
                .buttonStyle(.link)
#endif
                Button {
                    openUrl(URL(string: "https://www.themoviedb.org")!)
                } label: {
                    InformationalLabel(title: "acknowledgmentsContentProviderTitle",
                                       subtitle: "acknowledgmentsContentProviderSubtitle")
                }
#if os(macOS)
                .buttonStyle(.link)
#endif
                Button {
                    openUrl(URL(string: "https://github.com/SDWebImage/SDWebImageSwiftUI")!)
                } label: {
                    InformationalLabel(title: "acknowledgmentsSDWebImage")
                }
#if os(macOS)
                .buttonStyle(.link)
#endif
                Button {
                    openUrl(URL(string: "https://github.com/AvdLee/Roadmap")!)
                } label: {
                    InformationalLabel(title: "Roadmap")
                }
#if os(macOS)
                .buttonStyle(.link)
#endif
                Button {
                    openUrl(URL(string: "https://telemetrydeck.com/")!)
                } label: {
                    InformationalLabel(title: "TelemetryDeck")
                }
#if os(macOS)
                .buttonStyle(.link)
#endif
            } 
            
            Section {
                Button {
                    openUrl(URL(string: "https://github.com/MadeiraAlexandre/Cronica")!)
                } label: {
                    InformationalLabel(title: "cronicaGitHub")
                }
#if os(macOS)
                .buttonStyle(.link)
#endif
                
            }
            
            Section {
                CenterHorizontalView {
                    Text("Made in Brazil 🇧🇷")
                        .onTapGesture {
                            Task {
                                withAnimation {
                                    self.animateEasterEgg.toggle()
                                }
                                try? await Task.sleep(nanoseconds: 1_500_000_000)
                                withAnimation {
                                    self.animateEasterEgg.toggle()
                                }
                            }
                        }
                        .onLongPressGesture {
                            withAnimation { settings.displayDeveloperSettings.toggle() }
                        }
                        .font(animateEasterEgg ? .title3 : .caption)
                        .foregroundColor(animateEasterEgg ? .green : nil)
                        .animation(.easeInOut, value: animateEasterEgg)
                }
            }
        }
        .navigationTitle("aboutTitle")
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
    
    private func openUrl(_ url: URL) {
#if os(macOS)
        NSWorkspace.shared.open(url)
#else
        UIApplication.shared.open(url)
#endif
    }
}

struct AcknowledgementsSettings_Previews: PreviewProvider {
    static var previews: some View {
        AcknowledgementsSettings()
    }
}
