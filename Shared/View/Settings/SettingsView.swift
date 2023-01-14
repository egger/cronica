//
//  SettingsView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 22/03/22.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.openURL) var openURL
    @Environment(\.requestReview) var requestReview
    @AppStorage("displayDeveloperSettings") private var displayDeveloperSettings = false
    @State private var animateEasterEgg = false
    var body: some View {
        Form {
            developer
            general
            PrivacySupportSetting()
            Button {
                requestReview()
            } label: {
                Label("settingsReviewCronica", systemImage: "star.fill")
            }
            ShareLink(item: URL(string: "https://apple.co/3TV9SLP")!)
            about
        }
        .navigationDestination(for: SettingsScreen.self) { item in
            switch item {
            case .behavior:
                BehaviorSetting()
            case .sendFeedback:
                FeedbackSettingsView()
            case .appearance:
                AppearanceSetting()
            case .sync:
                SyncSetting()
            case .tipJar:
                TipJarSetting()
            case .acknowledgements:
                AcknowledgementsSettings()
            case .developer:
                DeveloperView()
            }
        }
    }
    
    @ViewBuilder
    private var developer: some View {
        if displayDeveloperSettings {
            NavigationLink(value: SettingsScreen.developer) {
                Label("settingsDeveloperOptions", systemImage: "hammer")
            }
        } else {
            EmptyView()
        }
    }
    
    private var general: some View {
        Section {
            NavigationLink(value: SettingsScreen.behavior) {
                Label("settingsBehaviorTitle", systemImage: "hand.tap")
            }
            NavigationLink(value: SettingsScreen.appearance) {
                Label("settingsAppearanceTitle", systemImage: "moon.stars")
            }
            NavigationLink(value: SettingsScreen.sync) {
                Label("settingsSyncTitle", systemImage: "arrow.triangle.2.circlepath")
            }
        } header: {
            Label("settingsGeneralTitle", systemImage: "wrench.adjustable")
        }
    }
    
    private var about: some View {
        Section {
            NavigationLink(value: SettingsScreen.tipJar) {
                Label("tipJarTitle", systemImage: "heart")
            }
            NavigationLink(value: SettingsScreen.acknowledgements) {
                Label("acknowledgmentsTitle", systemImage: "doc")
            }
#if os(iOS)
            Button {
                
            } label: {
                Label("developerWebsite", systemImage: "globe.americas.fill")
            }
#endif
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
                    .onLongPressGesture(perform: {
                        displayDeveloperSettings.toggle()
                    })
                    .font(animateEasterEgg ? .title3 : .caption)
                    .foregroundColor(animateEasterEgg ? .green : nil)
                    .animation(.easeInOut, value: animateEasterEgg)
            }
        } header: {
            Label("About", systemImage: "info.circle")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
