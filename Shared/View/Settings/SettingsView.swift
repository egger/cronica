//
//  SettingsView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 22/03/22.
//

import SwiftUI

/// Renders the Settings UI for each OS, support iOS, macOS, and tvOS.
struct SettingsView: View {
#if os(iOS)
    @Binding var showSettings: Bool
    @Environment(\.requestReview) var requestReview
    @State private var animateEasterEgg = false
    @StateObject private var settings = SettingsStore.shared
    static let tag: Screens? = .settings
#endif
    var body: some View {
#if os(iOS)
        iOSSettings
#elseif os(macOS)
        macOSSettings
#elseif os(tvOS)
        tvOSSettings
#endif
    }
    
#if os(tvOS)
    private var tvOSSettings: some View {
        Form {
            Section {
                NavigationLink(destination: SyncSetting()) {
                    Label("settingsSyncTitle", systemImage: "arrow.triangle.2.circlepath")
                }
            }
            
            PrivacySupportSetting()
            
            Section {
                NavigationLink(destination: TipJarSetting()) {
                    Label("tipJar", systemImage: "heart")
                }
            }
            
            CenterHorizontalView { Text("Made in Brazil 🇧🇷") }
        }
        .navigationTitle("Settings")
    }
#endif
    
#if os(iOS)
    private var iOSSettings: some View {
        NavigationStack {
            Form {
                // Developer section
                if settings.displayDeveloperSettings {
                    NavigationLink(value: SettingsScreens.developer) {
                        SettingsLabelWithIcon(title: "Developer Options", icon: "hammer", color: .purple)
                    }
                }
                
                // General section
                Section {
                    NavigationLink(value: SettingsScreens.behavior) {
                        SettingsLabelWithIcon(title: "settingsBehaviorTitle", icon: "hand.tap", color: .gray)
                    }
                    NavigationLink(value: SettingsScreens.appearance) {
                        SettingsLabelWithIcon(title: "settingsAppearanceTitle", icon: "paintbrush", color: .blue)
                    }
                    NavigationLink(value: SettingsScreens.sync) {
                        SettingsLabelWithIcon(title: "settingsSyncTitle", icon: "arrow.triangle.2.circlepath", color: .green)
                    }
                    NavigationLink(value: SettingsScreens.notifications) {
                        SettingsLabelWithIcon(title: "settingsNotificationTitle", icon: "bell", color: .red)
                    }
                }
                
                // Privacy and support section
                Section {
                    NavigationLink(destination: PrivacySupportSetting()) {
                        SettingsLabelWithIcon(title: "Privacy", icon: "hand.raised", color: .blue)
                    }
                    NavigationLink(destination: FeedbackSettingsView()) {
                        SettingsLabelWithIcon(title: "settingsFeedbackTitle", icon: "envelope.open", color: .teal)
                    }
                    NavigationLink(destination: FeatureRoadmap()) {
                        SettingsLabelWithIcon(title: "featureRoadmap", icon: "map", color: .pink)
                    }
                }
                
                Button {
                    requestReview()
                } label: {
                    Text("settingsReviewCronica")
                }
                ShareLink(item: URL(string: "https://apple.co/3TV9SLP")!)
                    .labelStyle(.titleOnly)
                
                // About section
                Section {
                    NavigationLink(destination: TipJarSetting()) {
                        SettingsLabelWithIcon(title: "tipJarTitle", icon: "heart", color: .red)
                    }
                    NavigationLink(destination: AcknowledgementsSettings()) {
                        SettingsLabelWithIcon(title: "acknowledgmentsTitle", icon: "doc", color: .yellow)
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
                                withAnimation { settings.displayDeveloperSettings.toggle() }
                            }
                            .font(animateEasterEgg ? .title3 : .caption)
                            .foregroundColor(animateEasterEgg ? .green : nil)
                            .animation(.easeInOut, value: animateEasterEgg)
                    }
                }
            }
            .toolbar {
                if UIDevice.isIPad { Button("Done") { showSettings = false } }
            }
            .navigationTitle("Settings")
            .navigationDestination(for: SettingsScreens.self) { settings in
                switch settings {
                case .acknowledgements: AcknowledgementsSettings()
                case .appearance: AppearanceSetting()
                case .behavior: BehaviorSetting()
                case .developer: DeveloperView()
                case .feedback: FeedbackSettingsView()
                case .notifications: NotificationsSettingsView()
                case .privacy: PrivacySupportSetting()
                case .roadmap: FeatureRoadmap()
                case .sync: SyncSetting()
                case .tipJar: TipJarSetting()
                default: BehaviorSetting()
                }
            }
        }
        .appTheme()
        .appTint()
    }
#endif
    
#if os(macOS)
    private var macOSSettings: some View {
        TabView {
            BehaviorSetting()
                .tabItem {
                    Label("settingsBehaviorTitle", systemImage: "cursorarrow.click")
                }
            AppearanceSetting()
                .tabItem {
                    Label("settingsAppearanceTitle", systemImage: "moon.stars")
                }
            SyncSetting()
                .tabItem {
                    Label("settingsSyncTitle", systemImage: "arrow.triangle.2.circlepath")
                }
            
            FeedbackSettingsView()
                .tabItem {
                    Label("Feedback", systemImage: "envelope.open.fill")
                }
            
            Form {
                PrivacySupportSetting()
            }
            .formStyle(.grouped)
            .tabItem {
                Label("Privacy", systemImage: "hand.raised.fill")
            }
            
            Form {
                FeatureRoadmap()
            }
            .formStyle(.grouped)
            .tabItem {
                Label("featureRoadmap", systemImage: "map")
            }
            
            TipJarSetting()
                .tabItem {
                    Label("tipJar", systemImage: "heart")
                }
            
            AcknowledgementsSettings()
                .tabItem {
                    Label("acknowledgmentsTitle", systemImage: "doc")
                }
        }
        .frame(minWidth: 720, idealWidth: 720, minHeight: 320, idealHeight: 320)
        .tabViewStyle(.automatic)
    }
#endif
}

struct SettingsView_Previews: PreviewProvider {
    @State private static var dismiss = false
    static var previews: some View {
#if os(iOS)
        SettingsView(showSettings: $dismiss)
#else
        SettingsView()
#endif
    }
}
