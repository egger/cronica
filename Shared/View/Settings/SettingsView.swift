//
//  SettingsView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 22/03/22.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.requestReview) var requestReview
    @AppStorage("displayDeveloperSettings") private var displayDeveloperSettings = false
    @State private var animateEasterEgg = false
    @Binding var showSettings: Bool
    @StateObject private var settings = SettingsStore.shared
    var body: some View {
        NavigationStack {
            Form {
                developer
                general
                privacySupport
                Button {
                    requestReview()
                } label: {
                    Label("settingsReviewCronica", systemImage: "star.fill")
                }
                ShareLink(item: URL(string: "https://apple.co/3TV9SLP")!)
                about
            }
            .toolbar {
                Button("Done") { showSettings = false }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .appTheme()
        .tint(settings.appTheme.color)
    }
    
    @ViewBuilder
    private var developer: some View {
        if displayDeveloperSettings {
            NavigationLink(destination: DeveloperView()) {
                Label("settingsDeveloperOptions", systemImage: "hammer")
            }
        } else {
            EmptyView()
        }
    }
    
    private var general: some View {
        Section {
            NavigationLink(destination: BehaviorSetting()) {
                Label("settingsBehaviorTitle", systemImage: "hand.tap")
            }
            NavigationLink(destination: AppearanceSetting()) {
                Label("settingsAppearanceTitle", systemImage: "moon.stars")
            }
            NavigationLink(destination: SyncSetting()) {
                Label("settingsSyncTitle", systemImage: "arrow.triangle.2.circlepath")
            }
        } header: {
            Label("settingsGeneralTitle", systemImage: "wrench.adjustable")
        }
    }
    
    private var privacySupport: some View {
        Section {
            NavigationLink(destination: PrivacySupportSetting()) {
                Label("Privacy", systemImage: "hand.raised")
            }
            NavigationLink(destination: FeedbackSettingsView()) {
                Label("settingsFeedbackTitle", systemImage: "mail")
            }
#if os(iOS)
            NavigationLink(destination: FeatureRoadmap()) {
                Label("featureRoadmap", systemImage: "map")
            }
#endif
        } header: {
            Label("settingsPrivacySupportTitle", systemImage: "hand.wave")
        }
    }
    
    private var about: some View {
        Section {
            NavigationLink(destination: TipJarSetting()) {
                Label("tipJarTitle", systemImage: "heart")
            }
            NavigationLink(destination: AcknowledgementsSettings()) {
                Label("acknowledgmentsTitle", systemImage: "doc")
            }
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
                        displayDeveloperSettings.toggle()
                    }
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
    @State private static var dismiss = false
    static var previews: some View {
        SettingsView(showSettings: $dismiss)
    }
}
